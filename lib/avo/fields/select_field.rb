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
        return options_from_computed_options if options.respond_to? :call
        return options_from_enum if enum.present?
        return options.map { |label, value| [value, value] }.to_h if display_value
        options
      end

      def label
        return value_from_computed_options if options.respond_to? :call
        return value_from_enum if enum.present?
        return value if display_value
        options.invert.with_indifferent_access[value]
      end

      private

      def options_from_computed_options
        return computed_options unless display_value

        computed_options = options.call model: model, resource: resource, view: view, field: self
        computed_options.map { |label, value| [value, value] }.to_h
      end

      def options_from_enum
        return options.invert if display_value

        # We need to use the label attribute as the option value because Rails casts it like that
        options.map { |label, value| [label, label] }.to_h
      end

      def value_from_computed_options
        return value if display_value

        computed_options = options.call model: model, resource: resource, view: view, field: self
        return computed_options.invert.stringify_keys[value]
      end

      def value_from_enum
        display_value ? options[value] : value
      end
    end
  end
end
