module Avo
  module Concerns
    module HasFields
      extend ActiveSupport::Concern

      included do
        class_attribute :fields
        class_attribute :fields_index, default: 0
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
    end
  end
end
