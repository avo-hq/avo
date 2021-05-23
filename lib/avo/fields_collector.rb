module Avo
  module FieldsCollector
    def field(field_name, as:, **args, &block)
      self.fields ||= []

      field_instance = parse_field(field_name, as: as, **args, &block)

      if field_instance.present?
        self.fields << field_instance
      else
        message = "[Avo] The #{field_name} field, as: #{as} from #{self.name} has an invalid configuration."
        ::Rails.logger.warn message
      end
    end

    def parse_field(field_name, as:, **args, &block)
      # The field is passed as a symbol eg: :text, :color_picker, :trix
      if as.is_a? Symbol
        field_class = field_class_from_symbol(as)

        if field_class.present?
          # The field has been registered before.
          instantiate_field(field_name, klass: field_class, **args, &block)
        else
          # The symbol can be transformed to a class and found.
          class_name = as.to_s.classify
          field_class = "#{class_name}Field"

          # Discover & load custom field classes
          if Object.const_defined? field_class
            instantiate_field(field_name, klass: field_class.safe_constantize, **args, &block)
          end
        end
      elsif as.is_a? Class
        # The field has been passed as a class.
        if Object.const_defined? as.to_s
          instantiate_field(field_name, klass: as, **args, &block)
        end
      end
    end

    def heading(body, **args)
      self.fields << Avo::Fields::HeadingField.new(body, **args)
    end

    private

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
  end
end
