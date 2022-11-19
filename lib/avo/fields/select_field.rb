module Avo
  module Fields
    class SelectField < BaseField
      include Avo::Fields::FieldExtensions::HasIncludeBlank

      attr_reader :options_from_args
      attr_reader :enum
      attr_reader :enum_type
      attr_reader :display_value

      def initialize(id, **args, &block)
        args[:placeholder] ||= I18n.t("avo.choose_an_option")

        super(id, **args, &block)

        @options_from_args = args[:options]
        if @options_from_args.is_a? Hash
          @options_from_args = ActiveSupport::HashWithIndifferentAccess.new @options_from_args
        end
        @enum = args[:enum].present? ? args[:enum] : nil
        @enum_type = args[:type].presence || :array if enum
        @display_value = args[:display_value].present? ? args[:display_value] : false
      end

      def options_for_select
        return options_from_enum if enum.present?
        return options_values if display_value
        options
      end

      def label
        return value_from_enum if enum.present?
        return value if display_value || options.is_a?(Array)
        options.invert.with_indifferent_access[value]
      end

      private

      def options_values
        options.is_a?(Array) ? options : options.values
      end

      def options_from_enum
        return enum.invert if display_value
        return enum if enum_type == :hash
        enum.map { |label, value| [label, label] }.to_h
      end

      def value_from_enum
        display_value ? enum[value] : value
      end

      def options
        @options ||= computed_options || options_from_args
      end

      def computed_options
        return nil unless options_from_args.respond_to? :call

        options_from_args.call model: model, resource: resource, view: view, field: self
      end
    end
  end
end
