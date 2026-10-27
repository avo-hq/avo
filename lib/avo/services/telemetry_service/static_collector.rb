# Prism is a default gem on Ruby 3.3+, so requiring it costs users nothing and
# needs no dependency declaration. On Ruby 3.2 (EOL) it may be absent — we skip
# the structural telemetry rather than make every app carry a parser for it.
begin
  require "prism"
rescue LoadError
end

module Avo
  module Services
    class TelemetryService
      # Collects the structural shape of an Avo install by parsing the
      # `app/avo` source files with Prism, instead of booting Rails and
      # instantiating every resource. It executes no user code, so it is cheap
      # and safe to run off the request path — which matters, because the
      # reporter runs in its own thread where `Avo::Current` is empty.
      #
      # It returns the same structural keys the runtime collector produced
      # (resource/field/action/filter counts and field-type breakdown). The
      # runtime-only values (menus, cache, config) are filled in by
      # TelemetryService itself, which has the live objects on hand.
      #
      #   Avo::Services::TelemetryService::StaticCollector.new(Rails.root).collect
      #
      # Known floor: a field declared in a loop counts once, and one behind a
      # conditional counts always. Static counts are a lower bound on what the
      # app defines, not a census of what a given request renders.
      class StaticCollector
        # Files are classified by their top-level directory under app/avo —
        # the same strong convention Avo's own autoloading relies on.
        #
        #   resource_tools/  Avo::BaseResourceTool         (avo)
        #   forms/           Avo::Forms::Core::Form        (avo-forms)
        #   pages/           Avo::Forms::Core::Page        (avo-forms)
        #
        # concerns/ holds shared modules rather than Avo entities. They are
        # parsed but never counted on their own — their contents are folded
        # into whichever resources include them.
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
            "pages" => :page,
            "concerns" => :concern
          }.freeze
        end

        # Kanban (avo-kanban) boards are ordinary resources backed by the Kanban
        # board model. There is no dedicated file type, so we recognize a board
        # by its `model_class` or by the `kanban_view` DSL the board reads.
        KANBAN_BOARD_MODEL = "Kanban::Board" unless const_defined?(:KANBAN_BOARD_MODEL)

        # `field :name` with no `as:` is a text field — Avo::Dsl::FieldParser
        # does `args.fetch(:as, :text)`.
        DEFAULT_FIELD_TYPE = :text unless const_defined?(:DEFAULT_FIELD_TYPE)

        # Avo's own field classes live under this namespace, but so do custom
        # fields defined in app/avo/fields — the namespace alone can't tell them
        # apart, so `custom_field_types_from` checks for an app-owned file too.
        CORE_FIELD_NAMESPACE = "Avo::Fields::" unless const_defined?(:CORE_FIELD_NAMESPACE)

        def initialize(app_root)
          @app_root = app_root.to_s
        end

        def collect
          return {} unless defined?(Prism)

          files = parse_files
          concerns = files.select { |f| f.kind == :concern }
          files.each { |file| absorb_concerns(file, concerns) }

          resources = files.select { |f| f.kind == :resource } + configured_resources(files)
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
            field_types: field_types(resources, custom_field_types),
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

        def avo_root
          @avo_root ||= File.join(@app_root, "app", "avo")
        end

        def parse_files
          ruby_files.filter_map do |path|
            kind = classify(path) or next
            parse(path, kind)
          end
        end

        def parse(path, kind)
          visitor = FileVisitor.new
          Prism.parse_file(path).value.accept(visitor)
          visitor.to_result(kind, path)
        rescue
          # One unreadable or oddly shaped file drops out of the counts; it never takes the rest with it.
          nil
        end

        def ruby_files
          return [] unless File.directory?(avo_root)

          Dir.glob(File.join(avo_root, "**", "*.rb"))
        end

        # Classify by the top-level directory under app/avo. Returns nil for
        # files outside the recognized directories, which the caller skips.
        def classify(path)
          relative = path.delete_prefix(avo_root).delete_prefix(File::SEPARATOR)
          top_dir = relative.split(File::SEPARATOR).first
          DIR_KINDS[top_dir]
        end

        # A concern's fields and actions belong to every resource that includes
        # it — at runtime they were part of the resource, so they count here
        # too. Concerns may include other concerns; each is resolved once, and
        # `resolved` keeps a shared concern from folding its own nested counts
        # in twice.
        def absorb_concerns(file, concerns, seen = Set.new)
          return file if file.resolved

          file.resolved = true

          file.includes.each do |name|
            concern = find_concern(concerns, name)
            next if concern.nil? || concern.equal?(file) || !seen.add?(concern.class_name)

            absorb_concerns(concern, concerns, seen)

            file.fields_count += concern.fields_count
            concern.field_types.each { |type, count| file.field_types[type] += count }
            file.custom_field_types.merge(concern.custom_field_types)
            file.actions.concat(concern.actions)
            file.filters.concat(concern.filters)
            file.kanban_view ||= concern.kanban_view
          end

          file
        end

        # `include Avo::Concerns::Sluggable` may name the module in full or rely
        # on the enclosing namespace, so fall back to matching the last segment.
        def find_concern(concerns, name)
          return nil if name.nil?

          concerns.find { |c| c.class_name == name } ||
            concerns.find { |c| c.class_name.to_s.split("::").last == name.split("::").last }
        end

        # Resources registered through `config.resources = [...]` in the Avo
        # initializer can live anywhere under app/, not just app/avo. Resolve
        # each one to its file by Zeitwerk naming and parse it like any other
        # resource. Entries we can't place (a gem's resource, say) are simply
        # not counted — there is no file of ours to read.
        def configured_resources(parsed)
          names = configured_resource_names
          return [] if names.empty?

          seen_paths = parsed.map(&:path).to_set

          names.filter_map do |name|
            path = resource_path_for(name)
            next if path.nil? || seen_paths.include?(path)

            seen_paths << path
            parse(path, :resource)
          end
        end

        def configured_resource_names
          initializer = File.join(@app_root, "config", "initializers", "avo.rb")
          return [] unless File.file?(initializer)

          visitor = ConfigVisitor.new
          Prism.parse_file(initializer).value.accept(visitor)
          visitor.resource_names
        rescue
          []
        end

        # `Avo::Resources::UserProfile` -> the app/ file that declares it.
        # Candidates come from the file name (Zeitwerk's own rule); parsing
        # confirms the match so a same-named class elsewhere can't slip in.
        def resource_path_for(name)
          Array(app_files_by_basename[name.split("::").last.underscore]).find do |path|
            declared = parse(path, :resource)&.class_name
            declared == name || declared.to_s.split("::").last == name.split("::").last
          end
        end

        # One traversal of app/, reused for every configured resource. Built
        # only when the initializer actually lists any.
        def app_files_by_basename
          @app_files_by_basename ||= Dir.glob(File.join(@app_root, "app", "**", "*.rb"))
            .group_by { |path| File.basename(path, ".rb") }
        end

        # Field type names whose class is defined inside the app itself
        # (app/avo/fields/*). These are the "custom" fields — a field wired by
        # symbol is only custom when the app owns a class for it.
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

        # The runtime counted a field as custom when its class was not one of
        # Avo's own (`custom?` checks the initialize source location), which
        # covers app-defined fields and gem-provided ones alike. Statically we
        # can see both shapes: a symbol matching an app-owned field class, and
        # `as:` pointing straight at a class outside Avo's namespace.
        def custom_fields_count(resources, custom_field_types)
          resources.sum do |resource|
            resource.field_types.sum do |type, count|
              custom_type?(resource, type, custom_field_types) ? count : 0
            end
          end
        end

        def custom_type?(resource, type, custom_field_types)
          custom_field_types.include?(type.to_s) || resource.custom_field_types.include?(type)
        end

        # Keys are strings to match the runtime `field.type` (e.g. "text").
        # A custom type is named by the app, so it leaves as `custom_1`,
        # `custom_2`, … (most used first) instead of its own name.
        def field_types(resources, custom_field_types)
          merged = Hash.new(0)
          resources.each do |resource|
            resource.field_types.each do |type, count|
              merged[[custom_type?(resource, type, custom_field_types), type.to_s]] += count
            end
          end

          custom_index = 0
          merged.sort_by { |(_, type), count| [-count, type] }.to_h do |(custom, type), count|
            [custom ? "custom_#{custom_index += 1}" : type, count]
          end
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

        # Reads `config.resources = [...]` out of the Avo initializer. Entries
        # may be constants or strings; both name a resource class.
        class ConfigVisitor < Prism::Visitor
          attr_reader :resource_names

          def initialize
            @resource_names = []
          end

          def visit_call_node(node)
            if node.name == :resources= && (array = node.arguments&.arguments&.first).is_a?(Prism::ArrayNode)
              @resource_names.concat(array.elements.filter_map { |element| constant_or_string(element) })
            end

            super
          end

          private

          def constant_or_string(node)
            case node
            when Prism::StringNode then node.unescaped.presence
            when Prism::ConstantReadNode, Prism::ConstantPathNode then Naming.constant_name(node)
            end
          end
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
            @custom_field_types = Set.new
            @actions = []
            @filters = []
            @includes = []
          end

          # `class Avo::Fields::ColorPickerField < ...` — record the first
          # (outermost) class name; used to identify app-defined custom fields.
          def visit_class_node(node)
            @class_name ||= Naming.constant_name(node.constant_path)
            super
          end

          # Concerns are modules, and they carry fields worth counting.
          def visit_module_node(node)
            @class_name ||= Naming.constant_name(node.constant_path)
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
              when :include then @includes.concat(constant_arguments(node))
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
          def to_result(kind, path = nil)
            Result.new(
              kind: kind,
              path: path,
              class_name: @class_name,
              model_class: @model_class,
              kanban_view: @kanban_view,
              fields_count: @fields_count,
              field_types: @field_types,
              custom_field_types: @custom_field_types,
              actions: @actions,
              filters: @filters,
              includes: @includes.compact,
              resolved: false
            )
          end

          private

          # A bare `field` with no arguments is not a declaration — it is the
          # block-local field object being read (`"#{field.id}": …`). Only a
          # call that names something can declare one.
          def record_field(node)
            return if node.arguments&.arguments.blank?

            @fields_count += 1

            as = as_argument(node)
            type = field_type(as)
            return if type.nil?

            @field_types[type] += 1
            @custom_field_types << type if custom_field_class?(as)
          end

          # `field :x, as: :text` and `field :x, as: MyField` are both valid —
          # FieldParser branches on Symbol vs Class. A class contributes the
          # same type name the runtime would report: `RadioField` -> "radio".
          # With no `as:` at all, Avo defaults to :text. A computed `as:` stays
          # unknown: the field is counted, its type can't be.
          def field_type(as)
            case as
            when nil then DEFAULT_FIELD_TYPE
            when Prism::SymbolNode then as.unescaped.to_sym
            when Prism::ConstantReadNode, Prism::ConstantPathNode then class_field_type(as)
            end
          end

          # A class-valued `as:` is a custom field unless it points back into
          # Avo's own namespace.
          def custom_field_class?(as)
            return false unless as.is_a?(Prism::ConstantReadNode) || as.is_a?(Prism::ConstantPathNode)

            !Naming.constant_name(as).to_s.delete_prefix("::").start_with?(CORE_FIELD_NAMESPACE)
          end

          def class_field_type(as)
            name = Naming.constant_name(as).to_s.split("::").last.to_s
            name.delete_suffix("Field").underscore.presence&.to_sym
          end

          def as_argument(node)
            args = node.arguments&.arguments or return nil
            hash = args.find { |a| a.is_a?(Prism::KeywordHashNode) || a.is_a?(Prism::HashNode) }
            return nil unless hash

            pair = hash.elements.find do |element|
              element.is_a?(Prism::AssocNode) &&
                element.key.is_a?(Prism::SymbolNode) &&
                element.key.unescaped == "as"
            end

            pair&.value
          end

          # `action Avo::Actions::Export` -> "Avo::Actions::Export". Returns nil
          # for dynamic wirings we can't name (counted by the caller as present
          # only when nameable, to keep `uniq` meaningful).
          def first_constant_argument(node)
            arg = node.arguments&.arguments&.first
            return nil unless arg.is_a?(Prism::ConstantReadNode) || arg.is_a?(Prism::ConstantPathNode)

            Naming.constant_name(arg)
          end

          # `include A, B` takes any number of modules.
          def constant_arguments(node)
            Array(node.arguments&.arguments).filter_map do |arg|
              Naming.constant_name(arg) if arg.is_a?(Prism::ConstantReadNode) || arg.is_a?(Prism::ConstantPathNode)
            end
          end

          # The value of `self.model_class = …`, whether a string literal
          # (`"Avo::Kanban::Board"`) or a constant (`Avo::Kanban::Board`).
          def string_or_constant_argument(node)
            arg = node.arguments&.arguments&.first
            case arg
            when Prism::StringNode then arg.unescaped
            when Prism::ConstantReadNode, Prism::ConstantPathNode then Naming.constant_name(arg)
            end
          end
        end

        module Naming
          # `full_name` raises on a dynamic path (`Foo::[bar]`); the source
          # slice is a good enough label for something we only compare.
          def self.constant_name(node)
            node.full_name
          rescue
            node.slice
          end
        end

        unless const_defined?(:Result)
          Result = Struct.new(:kind, :path, :class_name, :model_class, :kanban_view, :fields_count,
            :field_types, :custom_field_types, :actions, :filters, :includes, :resolved)
        end
      end
    end
  end
end
