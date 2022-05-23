module Avo
  module Concerns
    module HasFields
      extend ActiveSupport::Concern

      included do
        class_attribute :fields
        class_attribute :fields_index, default: 0
        class_attribute :tabs
        class_attribute :raw_tabs
      end

      class_methods do
        def field(field_name, as:, **args, &block)
          self.invalid_fields ||= []

          field_instance = parse_field(field_name, as: as, order_index: fields_index, **args, &block)

          if field_instance.present?
            add_to_fields field_instance
          else
            self.invalid_fields << ({
              name: field_name,
              as: as,
              resource: name,
              message: "There's an invalid field configuration for this resource. <br/> <code class='px-1 py-px rounded bg-red-600'>field :#{field_name}, as: #{as}</code>"
            })
          end
        end

        def parse_field(field_name, as:, **args, &block)
          # The field is passed as a symbol eg: :text, :color_picker, :trix
          if as.is_a? Symbol
            parse_symbol field_name, as: as, **args, &block
          elsif as.is_a? Class
            parse_class field_name, as: as, **args, &block
          end
        end

        def heading(body, **args)
          add_to_fields Avo::Fields::HeadingField.new(body, order_index: fields_index, **args)
        end

        def tab(name, **kargs, &block)
          puts ["tab->", name].inspect
          t = Avo::Concerns::Builder.parse_block(name: name, &block)
          puts ["t->", t].inspect
          self.tabs ||= []
          # self.raw_tabs ||= []

          # # self.raw_tabs << [args, kargs, block]

          # new_tab = Tab.new

          # # tab.fields

          # tools_and_fields = new_tab.class_eval(&block)

          # puts ["new_tab->", new_tab, tools_and_fields].inspect
          # new_tab.class.tools_holder = tools_and_fields

          self.tabs << t
        end

        private

        def add_to_fields(instance)
          self.fields ||= []
          self.fields << instance
          self.fields_index += 1
        end

        def instantiate_field(field_name, klass:, **args, &block)
          if block
            klass.new(field_name, **args || {}, &block)
          else
            klass.new(field_name, **args || {})
          end
        end

        def field_class_from_symbol(symbol)
          matched_field = Avo::App.fields.find do |field|
            field[:name].to_s == symbol.to_s
          end

          return matched_field[:class] if matched_field.present? && matched_field[:class].present?
        end

        def parse_symbol(field_name, as:, **args, &block)
          field_class = field_class_from_symbol(as)

          if field_class.present?
            # The field has been registered before.
            instantiate_field(field_name, klass: field_class, **args, &block)
          else
            # The symbol can be transformed to a class and found.
            class_name = as.to_s.camelize
            field_class = "#{class_name}Field"

            # Discover & load custom field classes
            if Object.const_defined? field_class
              instantiate_field(field_name, klass: field_class.safe_constantize, **args, &block)
            end
          end
        end

        def parse_class(field_name, as:, **args, &block)
          # The field has been passed as a class.
          if Object.const_defined? as.to_s
            instantiate_field(field_name, klass: as, **args, &block)
          end
        end
      end

      def get_tabs
        self.tabs
      end

      def get_field_definitions
        return [] if self.class.fields.blank?

        fields = self.class.fields.map do |field|
          field.hydrate(resource: self, panel_name: default_panel_name, user: user, translation_enabled: translation_enabled)
        end

        if Avo::App.license.lacks_with_trial(:custom_fields)
          fields = fields.reject do |field|
            field.custom?
          end
        end

        if Avo::App.license.lacks_with_trial(:advanced_fields)
          fields = fields.reject do |field|
            field.type == "tags"
          end
        end

        fields
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
    end
  end
end

# class Avo::Concerns::Builder
class Avo::Concerns::Builder
  class << self
    def parse_block(**args, &block)
      Docile.dsl_eval(Avo::Concerns::Builder.new(**args), &block).build
    end
  end

  delegate :add_tool, to: ::Avo::Services::DslService

  def initialize(name: nil, items: [], **args)
    @tab = Avo::Tab.new(name: name, **args)

    # @tab.name = name
    # @tab.tools = items
    @tab.fields_holder = []
    @tab.tools_holder = []
  end

  # Adds a link
  def field(name, **args)
    puts ["B field->", name].inspect
    @tab.fields_holder << name
  end

  # Adds a link
  def tool(klass, **args)
    add_tool @tab.tools_holder, klass, **args
    # @tab.tools_holder << klass.new(**args)
  end

  # Fetch the tab
  def build
    @tab
  end
end
