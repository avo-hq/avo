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
        delegate :add_tool, to: ::Avo::Services::DslService
        delegate :tool, to: :items_holder

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

        def heading(body, **args)
          self.items_holder.add_item Avo::Fields::HeadingField.new(body, order_index: items_index, **args)
        end

        def fields
          self.items.select do |item|
            next if item.nil?

            item.is_field?
          end
        end

        def tab_groups
          self.items.select do |item|
            item.instance_of? Avo::TabGroup
          end
        end

        private

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

      def fields
        self.class.fields
      end

      def tab_groups
        self.class.tab_groups
      end

      def get_field_definitions
        fields = self.class.fields

        return [] if fields.blank?

        items = fields.map do |field|
          field.hydrate(resource: self, panel_name: default_panel_name, user: user)
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

      def get_fields(panel: nil, reflection: nil)
        fields = get_field_definitions
          .select do |field|
            field.send("show_on_#{@view}")
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
                    reflection.inverse_of.foreign_key == field.foreign_key
                  is_valid = false
                end

                # polymorphic association
                if field.respond_to?(:foreign_key) &&
                    field.is_polymorphic? &&
                    reflection.respond_to?(:polymorphic?) &&
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
        # abort self.class.tools.inspect
        # abort self.inspect
        check_license

        return [] if App.license.lacks_with_trial :resource_tools
        return [] if self.class.tools.blank?
        # abort self.class.tools_holder.inspect

        # .map do |tool|
        #   tool.hydrate view: view
        #   tool
        # end
        # .select do |field|
        #   # field.send("show_on_#{view}")
        #   true
        # end
        # [3,4,5]
        self.items.select do |item|
          next if item.nil?

          item.is_tool?
        end
      end

      def get_items
        # return items

        panelless_items = []
        panelfull_items = []

        items.each do |item|
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

        # panelfull_items = items.select do |item|
        #   if item.is_field? && item.has_own_panel?
        #     false
        #   else
        #     true
        #   end
        # end

        puts ["panelfull_fields->", items.count, panelfull_items.count, panelless_items.count, items.map(&:item_type)].inspect

        i_holder = Avo::ItemsHolder.new
        i_holder.items = panelless_items

        main_panel = Avo::MainPanel.new(name: default_panel_name, description: resource_description)
        main_panel.items_holder = i_holder

        [main_panel, *panelfull_items]
      end

      def get_base_items
        panelless_fields = items.select do |field|
          field.is_field? && !field.has_own_panel?
        end

        panelless_fields

        # panelfull_fields = items.select do |field|
        #   field.is_field? && field.has_own_panel?
        # end

        # puts ["panelfull_fields->", panelfull_fields.count, panelless_fields.count].inspect

        # [Avo::Panel.new(name: default_panel_name, description: resource_description, items: panelless_fields, is_main_panel: true), *panelfull_fields]
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
