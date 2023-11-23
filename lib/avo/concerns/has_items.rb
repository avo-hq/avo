module Avo
  module Concerns
    module HasItems
      extend ActiveSupport::Concern

      class_methods do
        def deprecated_dsl_api(name, method)
          message = "This API was deprecated. Please use the `#{name}` method inside the `#{method}` method."
          raise DeprecatedAPIError.new message
        end

        # DSL methods
        def field(name, as: :text, **args, &block)
          deprecated_dsl_api __method__, "fields"
        end

        def panel(name = nil, **args, &block)
          deprecated_dsl_api __method__, "fields"
        end

        def row(**args, &block)
          deprecated_dsl_api __method__, "fields"
        end

        def tabs(**args, &block)
          deprecated_dsl_api __method__, "fields"
        end

        def tool(klass, **args)
          deprecated_dsl_api __method__, "fields"
        end

        def sidebar(**args, &block)
          deprecated_dsl_api __method__, "fields"
        end
        # END DSL methods
      end

      attr_writer :items_holder

      delegate :invalid_fields, to: :items_holder

      delegate :field, to: :items_holder
      delegate :panel, to: :items_holder
      delegate :row, to: :items_holder
      delegate :tabs, to: :items_holder
      delegate :tool, to: :items_holder
      delegate :heading, to: :items_holder
      delegate :sidebar, to: :items_holder
      delegate :main_panel, to: :items_holder

      def items_holder
        @items_holder || Avo::Resources::Items::Holder.new
      end

      # def items
      #   items_holder.items
      # end

      def invalid_fields
        invalid_fields = items_holder.invalid_fields

        items_holder.items.each do |item|
          if item.respond_to? :items
            invalid_fields += item.invalid_fields
          end
        end

        invalid_fields
      end

      def fields(**args)
        self.class.fields(**args)
      end

      def tab_groups
        self.class.tab_groups
      end

      # Dives deep into panels and tabs to fetch all the fields for a resource.
      def only_fields(only_root: false)
        fields = []

        items.each do |item|
          next if item.nil?

          unless only_root
            # Dive into panels to fetch their fields
            if item.is_panel?
              fields << extract_fields(item)
            end

            # Dive into tabs to fetch their fields
            if item.is_tab_group?
              item.items.map do |tab|
                fields << extract_fields(tab)
              end
            end

            # Dive into sidebar to fetch their fields
            if item.is_sidebar?
              fields << extract_fields(item)
            end
          end

          if item.is_field?
            fields << item
          end

          if item.is_row?
            fields << extract_fields(tab)
          end

          if item.is_main_panel?
            fields << extract_fields(item)
          end
        end

        fields.flatten
      end

      def get_field_definitions(only_root: false)
        only_fields(only_root: only_root).map do |field|
          field.hydrate(resource: self, user: user, view: view)
        end
      end

      def get_preview_fields
        get_field_definitions.select do |field|
          field.visible_in_view?(view: :preview)
        end
      end

      def get_fields(panel: nil, reflection: nil, only_root: false)
        fields = get_field_definitions(only_root: only_root)
          .select do |field|
            # Get the fields for this view
            field.visible_in_view?(view: view)
          end
          .select do |field|
            field.visible?
          end
          .select do |field|
            is_valid = true

            # Strip out the reflection field in index queries with a parent association.
            if reflection.present?
              # regular non-polymorphic association
              # we're matching the reflection inverse_of foriegn key with the field's foreign_key
              if field.is_a?(Avo::Fields::BelongsToField)
                if field.respond_to?(:foreign_key) &&
                    reflection.inverse_of.present? &&
                    reflection.inverse_of.respond_to?(:foreign_key) &&
                    reflection.inverse_of.foreign_key == field.foreign_key
                  is_valid = false
                end

                # polymorphic association
                if field.respond_to?(:foreign_key) &&
                    field.is_polymorphic? &&
                    reflection.respond_to?(:polymorphic?) &&
                    reflection.inverse_of.respond_to?(:foreign_key) &&
                    reflection.inverse_of.foreign_key == field.reflection.foreign_key
                  is_valid = false
                end
              end
            end

            is_valid
          end

        if panel.present?
          fields = fields.select do |field|
            field.panel_name == panel
          end
        end

        # hydrate_fields fields
        fields.each do |field|
          field.hydrate(record: @record, view: @view, resource: self)
        end

        fields
      end

      def get_field(id)
        get_field_definitions.find do |f|
          f.id == id.to_sym
        end
      end

      def tools
        return [] if self.class.tools.blank?

        items
          .select do |item|
            next if item.nil?

            item.is_tool?
          end
          .map do |tool|
            tool.hydrate view: view
            tool
          end
          .select do |item|
            item.visible_in_view?(view: view)
          end
      end

      def get_items
        # Each group is built only by standalone items or items that have their own panel, keeping the items order
        grouped_items = visible_items.slice_when do |prev, curr|
          # Slice when the item type changes from standalone to panel or vice-versa
          is_standalone?(prev) != is_standalone?(curr)
        end.to_a.map do |group|
          { elements: group, is_standalone: is_standalone?(group.first) }
        end

        # Creates a main panel if it's missing and adds first standalone group of items if present
        if items.none? { |item| item.is_main_panel? }
          if (standalone_group = grouped_items.find { |group| group[:is_standalone] }).present?
            calculated_main_panel = Avo::Resources::Items::MainPanel.new
            hydrate_item calculated_main_panel
            calculated_main_panel.items_holder.items = standalone_group[:elements]
            grouped_items[grouped_items.index standalone_group] = { elements: [calculated_main_panel], is_standalone: false }
          end
        end

        # For each standalone group, wrap items in a panel
        grouped_items.select { |group| group[:is_standalone] }.each do |group|
          calculated_panel = Avo::Resources::Items::Panel.new
          calculated_panel.items_holder.items = group[:elements]
          hydrate_item calculated_panel
          group[:elements] = calculated_panel
        end

        grouped_items.flat_map { |group| group[:elements] }
      end

      def items
        items_holder&.items || []
      end

      def visible_items
        items
          .map do |item|
            hydrate_item item

            if item.is_a? Avo::Resources::Items::TabGroup
              # Set the target to _top for all belongs_to fields in the tab group
              item.items.grep(Avo::Resources::Items::Tab).each do |tab|
                tab.items.grep(Avo::Resources::Items::Panel).each do |panel|
                  set_target_to_top panel.items.grep(Avo::Fields::BelongsToField)

                  panel.items.grep(Avo::Resources::Items::Row).each do |row|
                    set_target_to_top row.items.grep(Avo::Fields::BelongsToField)
                  end
                end
              end
            end

            item
          end
          .select do |item|
            item.visible?
          end
          .select do |item|
            if item.respond_to?(:visible_in_view?)
              item.visible_in_view? view: view
            else
              true
            end
          end
          .select do |item|
            # On location field we can have field coordinates and setters with different names like latitude and longitude
            if !item.is_a?(Avo::Fields::LocationField) && !item.is_heading? && view.in?(%w[edit update new create])
              if item.respond_to?(:id)
                item.resource.record.respond_to?("#{item.id}=")
              else
                true
              end
            else
              true
            end
          end
          .select do |item|
            # Check if the user is authorized to view it.
            # This is usually used for has_* fields
            if item.respond_to? :authorized?
              item.authorized?
            else
              true
            end
          end
          .select do |item|
            !item.is_a?(Avo::Resources::Items::Sidebar)
          end.compact
      end

      def is_empty?
        visible_items.blank?
      end

      private

      def set_target_to_top(fields)
        fields.each do |field|
          field.target = :_top
        end
      end

      # Extracts fields from a structure
      # Structures can be panels, rows and sidebars
      def extract_fields(structure)
        structure.items.map do |item|
          if item.is_field?
            item
          elsif extractable_structure?(item)
            extract_fields(item)
          else
            nil
          end
        end.compact
      end

      # Extractable structures are panels, rows and sidebars
      # Sidebars are only extractable if they are not on the index view
      def extractable_structure?(structure)
        structure.is_panel? || structure.is_row? || (structure.is_sidebar? && !view.index?)
      end

      # Standalone items are fields that don't have their own panel
      def is_standalone?(item)
        item.is_field? && !item.has_own_panel?
      end

      def hydrate_item(item)
        return unless item.respond_to? :hydrate

        res = self.class.ancestors.include?(Avo::BaseResource) ? self : resource
        item.hydrate(view: view, resource: res)
      end
    end
  end
end
