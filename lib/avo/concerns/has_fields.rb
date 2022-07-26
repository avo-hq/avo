module Avo
  module Concerns
    module HasFields
      extend ActiveSupport::Concern

      included do
        class_attribute :items_holder
        class_attribute :items_index, default: 0
        class_attribute :tabs_holder
        class_attribute :tabs_tabs_holder
        class_attribute :raw_tabs
        class_attribute :tools_holder
      end

      class_methods do
        # DSL methods
        def field(name, **args, &block)
          ensure_items_holder_initialized

          self.items_holder.field name, **args, &block
        end

        def panel(name = nil, **args, &block)
          ensure_items_holder_initialized

          self.items_holder.panel name, **args, &block
        end

        def tabs(&block)
          ensure_items_holder_initialized

          self.items_holder.tabs Avo::TabGroupBuilder.parse_block(&block)
        end

        def tool(klass, **args)
          ensure_items_holder_initialized

          items_holder.tool klass, **args
        end

        def heading(body, **args)
          self.items_holder.add_item Avo::Fields::HeadingField.new(body, order_index: items_index, **args)
        end
        # END DSL methods

        def items
          if self.items_holder.present?
            self.items_holder.items
          else
            []
          end
        end

        def tools
          self.tools_holder
        end

        # Dives deep into panels and tabs to fetch all the fields for a resource.
        def fields(only_root: false)
          fields = []

          self.items.each do |item|
            next if item.nil?

            unless only_root
              # Dive into panels to fetch their fields
              if item.is_panel?
                fields << extract_fields_from_items(item)
              end

              # Dive into tabs to fetch their fields
              if item.is_tab_group?
                item.items.map do |tab|
                  fields << extract_fields_from_items(tab)
                end
              end
            end


            if item.is_field?
              fields << item
            end
          end

          fields.flatten
        end

        def tab_groups
          self.items.select do |item|
            item.instance_of? Avo::TabGroup
          end
        end

        private

        def extract_fields_from_items(thing)
          fields = []

          thing.items.each do |item|
            if item.is_field?
              fields << item
            elsif item.is_panel?
              fields << extract_fields_from_items(item)
            end
          end

          fields
        end

        def ensure_items_holder_initialized
          self.items_holder ||= Avo::ItemsHolder.new
        end

        def add_to_fields(instance)
          self.items ||= []
          self.items << instance
          increment_order_index
        end

        def increment_order_index
          self.items_index += 1
        end
      end

      delegate :invalid_fields, to: :items_holder
      delegate :items, to: :items_holder

      def hydrate_fields(model: nil, view: nil)
        fields.map do |field|
          field.hydrate(model: @model, view: @view, resource: self)
        end

        self
      end

      def get_tabs
        tabs_holder
      end

      def fields(**args)
        self.class.fields(**args)
      end

      def tab_groups
        self.class.tab_groups
      end

      def get_field_definitions(only_root: false)
        fields = self.fields(only_root: only_root)

        return [] if fields.blank?

        items = fields.map do |field|
          field.hydrate(resource: self, user: user, view: view)
        end

        if Avo::App.license.lacks_with_trial(:custom_fields)
          items = items.reject do |field|
            field.custom?
          end
        end

        if Avo::App.license.lacks_with_trial(:advanced_fields)
          items = items.reject do |field|
            field.type == "tags"
          end
        end

        items
      end

      def get_fields(panel: nil, reflection: nil, only_root: false)
        fields = get_field_definitions(only_root: only_root)
          .select do |field|
            field.visible_on?(view)
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

        hydrate_fields(model: @model, view: @view)

        fields
      end

      def get_field(id)
        get_field_definitions.find do |f|
          f.id == id.to_sym
        end
      end

      def tools
        check_license

        return [] if App.license.lacks_with_trial :resource_tools
        return [] if self.class.tools.blank?

        self.items
          .select do |item|
            next if item.nil?

            item.is_tool?
          end
          .map do |tool|
            tool.hydrate view: view
            tool
          end
          .select do |item|
            item.visible_on?(view)
          end
      end

      # Separates the fields that are in a panel and those that are just hanging out.
      # Take the ones that aren't placed into a panel and add them to the "default" panel.
      # This is to keep compatibility with the versions before 2.10 when you didn't have the ability to add fields to panels.
      def get_items
        panelless_items = []
        panelfull_items = []

        items.each do |item|
          # fields and tabs can be hidden on some views
          if item.respond_to? :visible_on?
            next unless item.visible_on?(view)
          end
          # each field has it's own visibility checker
          if item.respond_to? :visible?
            next unless item.visible?
          end
          # check if the user is authorized to view it
          if item.respond_to? :authorized?
            next unless item.hydrate(model: @model).authorized?
          end

          if item.is_field?
            if item.has_own_panel?
              panelfull_items << item
            else
              panelless_items << item
            end
          else
            panelfull_items << item
          end
        end

        # Add all the panelles fields to a new panel
        main_panel_holder = Avo::ItemsHolder.new
        main_panel_holder.items = panelless_items

        # Add that panel to the main panel
        main_panel = Avo::MainPanel.new
        main_panel.items_holder = main_panel_holder

        # Return all the items but this time with all the panelless ones inside the main panel
        [main_panel, *panelfull_items]
      end

      private

      def check_license
        if !Rails.env.production? && App.license.present? && App.license.lacks(:resource_tools)
          # Add error message to let the developer know the resource tool will not be available in a production environment.
          Avo::App.error_messages.push "Warning: Your license is invalid or doesn't support resource tools. The resource tools will not be visible in a production environment."
        end
      end
    end
  end
end
