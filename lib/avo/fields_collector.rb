module Avo
  module FieldsCollector
    def field(field_name, as:, **args, &block)
      self.fields ||= []

      self.fields << parse_field(field_name, as: as, **args, &block)
    end

    def parse_field(field_name, as:, **args, &block)
      matched_field = Avo::App.fields.find do |field|
        field[:name].to_s == as.to_s
      end

      if matched_field.present? && matched_field[:class].present?
        klass = matched_field[:class]

        if block
          klass.new(field_name, **args || {}, &block)
        else
          klass.new(field_name, **args || {})
        end

      end
    end

    def heading(body, **args)
      self.fields << Avo::Fields::HeadingField.new(body, **args)
    end
  end
end
