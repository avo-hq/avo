require "prism"

module Avo
  module Services
    class TelemetryService
      # Collects the structural shape of an Avo install by parsing the
      # `app/avo` source files with Prism, instead of booting Rails and
      # instantiating every resource. It executes no user code, so it is cheap
      # and safe to run off the request path.
      #
      # It returns the same structural keys the runtime collector produced
      # (resource/field/action/filter counts and field-type breakdown). The
      # runtime-only values (menus, cache, config) are filled in by
      # TelemetryService itself, which has the live objects on hand.
      #
      #   Avo::Services::TelemetryService::StaticCollector.new(Rails.root.join("app/avo")).collect
      class StaticCollector
        # Files are classified by their top-level directory under app/avo —
        # the same strong convention Avo's own autoloading relies on. Directories
        # not listed here (concerns/, plugins/) are ignored.
        #
        #   resource_tools/  Avo::BaseResourceTool         (avo)
        #   forms/           Avo::Forms::Core::Form        (avo-forms)
        #   pages/           Avo::Forms::Core::Page        (avo-forms)
        unless const_defined?(:DIR_KINDS)
          DIR_KINDS = {
            "resources" => :resource,
            "actions" => :action,
            "filters" => :filter,
            "dashboards" => :dashboard,
            "cards" => :card,
            "fields" => :field,
            "resource_tools" => :tool,
            "forms" => :form,
            "pages" => :page
          }.freeze
        end

        # Kanban (avo-kanban) boards are ordinary resources backed by the Kanban
        # board model. There is no dedicated file type, so we recognize a board
        # by its `model_class` or by the `kanban_view` DSL the board reads.
        KANBAN_BOARD_MODEL = "Kanban::Board" unless const_defined?(:KANBAN_BOARD_MODEL)

        def initialize(avo_root)
          @avo_root = avo_root.to_s
        end

        def collect
          files = parse_files

          resources = files.select { |f| f.kind == :resource }
          forms = files.select { |f| f.kind == :form }
          custom_field_types = custom_field_types_from(files)

          fields_count = resources.sum(&:fields_count)
          resources_count = resources.size

          {
            resources_count: resources_count,
            dashboards_count: files.count { |f| f.kind == :dashboard },
            fields_count: fields_count,
            fields_per_resource: average(fields_count, resources_count),
            custom_fields_count: custom_fields_count(resources, custom_field_types),
            field_types: field_types(resources),
            actions_count: distinct_count(resources, :actions),
            actions_per_resource: average(total_wired(resources, :actions), resources_count),
            filters_count: distinct_count(resources, :filters),
            filters_per_resource: average(total_wired(resources, :filters), resources_count),
            boards_count: resources.count { |r| board?(r) },
            tools_count: files.count { |f| f.kind == :tool },
            forms_count: forms.size,
            form_fields_count: forms.sum(&:fields_count),
            pages_count: files.count { |f| f.kind == :page }
          }
        end

        private

        def parse_files
          ruby_files.filter_map do |path|
            kind = classify(path) or next
            visitor = FileVisitor.new
            Prism.parse_file(path).value.accept(visitor)
            visitor.to_result(kind)
          end
        end

        def ruby_files
          return [] unless File.directory?(@avo_root)

          Dir.glob(File.join(@avo_root, "**", "*.rb"))
        end

        # Classify by the top-level directory under app/avo. Returns nil for
        # files outside the recognized directories, which the caller skips.
        def classify(path)
          relative = path.delete_prefix(@avo_root).delete_prefix(File::SEPARATOR)
          top_dir = relative.split(File::SEPARATOR).first
          DIR_KINDS[top_dir]
        end

        # Field type names whose class is defined inside the app itself
        # (app/avo/fields/*). These are the "custom" fields — gem-provided field
        # types are not counted, matching the runtime `field.custom?` intent.
        def custom_field_types_from(files)
          files.select { |f| f.kind == :field }
            .map { |f| field_type_from_class_name(f.class_name) }
            .compact
            .to_set
        end

        # `Avo::Fields::ColorPickerField` -> "color_picker"
        def field_type_from_class_name(class_name)
          return nil unless class_name

          class_name.split("::").last.delete_suffix("Field").underscore.presence
        end

        # A resource is a kanban board if it is backed by the Kanban board model
        # or defines the `kanban_view` DSL the board UI reads.
        def board?(resource)
          resource.kanban_view || resource.model_class.to_s.include?(KANBAN_BOARD_MODEL)
        end

        def custom_fields_count(resources, custom_field_types)
          return 0 if custom_field_types.empty?

          resources.sum do |resource|
            resource.field_types.sum { |type, count| custom_field_types.include?(type.to_s) ? count : 0 }
          end
        end

        # Keys are strings to match the runtime `field.type` (e.g. "text").
        def field_types(resources)
          merged = Hash.new(0)
          resources.each { |r| r.field_types.each { |type, count| merged[type.to_s] += count } }
          merged.sort_by { |_, count| -count }.to_h
        end

        # Distinct wired classes across all resources (e.g. the same action used
        # on three resources counts once), matching `get_actions.uniq.count`.
        # Only nameable (constant) wirings count; dynamic ones can't be deduped.
        def distinct_count(resources, kind)
          resources.flat_map { |r| r.public_send(kind).compact }.uniq.count
        end

        # Total wirings including dynamic ones, matching `map(&:count).sum`.
        def total_wired(resources, kind)
          resources.sum { |r| r.public_send(kind).count }
        end

        # Mirrors the runtime collector's `sprintf("%0.01f", …)` — a string.
        def average(count, divisor)
          return "0.0" if divisor.zero?

          sprintf("%0.01f", count / (divisor + 0.0))
        end

        # One parsed file's tally. Walks the AST counting the receiverless DSL
        # calls (`field`, `action`, `filter`) and capturing the class shape.
        class FileVisitor < Prism::Visitor
          attr_reader :class_name

          def initialize
            @class_name = nil
            @model_class = nil
            @kanban_view = false
            @fields_count = 0
            @field_types = Hash.new(0)
            @actions = []
            @filters = []
          end

          # `class Avo::Fields::ColorPickerField < ...` — record the first
          # (outermost) class name; used to identify app-defined custom fields.
          def visit_class_node(node)
            @class_name ||= constant_name(node.constant_path)
            super
          end

          # The DSL methods are calls with no explicit receiver:
          #   field :name, as: :text   /   action Avo::Actions::Export
          # We also note resource-level config used to detect kanban boards:
          #   self.model_class = "Avo::Kanban::Board"   /   self.kanban_view = …
          def visit_call_node(node)
            if node.receiver.nil?
              case node.name
              when :field then record_field(node)
              when :action then @actions << first_constant_argument(node)
              when :filter then @filters << first_constant_argument(node)
              end
            end

            case node.name
            when :model_class= then @model_class = string_or_constant_argument(node)
            when :kanban_view, :kanban_view= then @kanban_view = true
            end

            super
          end

          # Catches `def self.kanban_view` / `def kanban_view`.
          def visit_def_node(node)
            @kanban_view = true if node.name == :kanban_view
            super
          end

          # Returns a struct-like result tagged with the file's classification.
          def to_result(kind)
            Result.new(
              kind: kind,
              class_name: @class_name,
              model_class: @model_class,
              kanban_view: @kanban_view,
              fields_count: @fields_count,
              field_types: @field_types,
              actions: @actions,
              filters: @filters
            )
          end

          private

          def record_field(node)
            @fields_count += 1
            type = field_type(node)
            @field_types[type] += 1 if type
          end

          # Pull the `as:` symbol from `field :x, as: :text`. Returns nil when
          # `as:` is dynamic (a method call/variable) — we still count the field
          # but can't statically name its type.
          def field_type(node)
            args = node.arguments&.arguments or return nil
            hash = args.find { |a| a.is_a?(Prism::KeywordHashNode) || a.is_a?(Prism::HashNode) }
            return nil unless hash

            pair = hash.elements.find do |element|
              element.is_a?(Prism::AssocNode) &&
                element.key.is_a?(Prism::SymbolNode) &&
                element.key.unescaped == "as"
            end
            return nil unless pair&.value.is_a?(Prism::SymbolNode)

            pair.value.unescaped.to_sym
          end

          # `action Avo::Actions::Export` -> "Avo::Actions::Export". Returns nil
          # for dynamic wirings we can't name (counted by the caller as present
          # only when nameable, to keep `uniq` meaningful).
          def first_constant_argument(node)
            arg = node.arguments&.arguments&.first
            return nil unless arg.is_a?(Prism::ConstantReadNode) || arg.is_a?(Prism::ConstantPathNode)

            constant_name(arg)
          end

          # The value of `self.model_class = …`, whether a string literal
          # (`"Avo::Kanban::Board"`) or a constant (`Avo::Kanban::Board`).
          def string_or_constant_argument(node)
            arg = node.arguments&.arguments&.first
            case arg
            when Prism::StringNode then arg.unescaped
            when Prism::ConstantReadNode, Prism::ConstantPathNode then constant_name(arg)
            end
          end

          def constant_name(node)
            node.full_name
          rescue
            node.slice
          end
        end

        unless const_defined?(:Result)
          Result = Struct.new(:kind, :class_name, :model_class, :kanban_view, :fields_count, :field_types, :actions, :filters)
        end
      end
    end
  end
end
