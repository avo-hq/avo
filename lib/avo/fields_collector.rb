# require "active_support/inflector"

module Avo
  module FieldsCollector
    def field(field_name, as:, **args, &block)
      self.fields ||= []

      self.fields << parse_field(field_name, as: as, **args, &block)
    end

    def parse_field(field_name, as:, **args, &block)
      class_name = as.to_s.classify
      # Discover & autoload custom field classes
      Object.const_defined? "#{class_name}::#{class_name}Field"

      # try and find the field in the base fields
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
