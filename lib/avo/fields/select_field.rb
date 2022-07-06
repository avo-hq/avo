module Avo
  module Fields
    class SelectField < BaseField
      include Avo::Fields::FieldExtensions::HasIncludeBlank

      attr_reader :options
      attr_reader :enum
      attr_reader :display_value

      def initialize(id, **args, &block)
        args[:placeholder] ||= I18n.t("avo.choose_an_option")

        super(id, **args, &block)

        @options = args[:options] || args[:enum]
        @options = ActiveSupport::HashWithIndifferentAccess.new @options if @options.is_a? Hash
        @enum = args[:enum].present? ? args[:enum] : nil
        @display_value = args[:display_value].present? ? args[:display_value] : false
      end

      def options_for_select
        if options.respond_to? :call
          computed_options = options.call model: model, resource: resource, view: view, field: self
          if display_value
            computed_options.map { |label, value| [value, value] }.to_h
          else
            computed_options
          end
        elsif enum.present?
          if display_value
            options.invert
          else
            options.map { |label, value| [label, label] }.to_h
          end
        elsif display_value
          options.map { |label, value| [value, value] }.to_h
        else
          options
        end
      end

      def label
        if options.respond_to? :call
          computed_options = options.call model: model, resource: resource, view: view, field: self

          return value if display_value

          computed_options.invert.stringify_keys[value]
        elsif enum.present?
          if display_value
            options[value]
          else
            value
          end
        elsif display_value
          value
        else
          options.invert.stringify_keys[value]
        end
      end
    end
  end
end
