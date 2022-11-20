module Avo
  module Fields
    class SelectField < BaseField
      include Avo::Fields::FieldExtensions::HasIncludeBlank

      attr_reader :options_from_args
      attr_reader :enum
      attr_reader :display_value

      def initialize(id, **args, &block)
        args[:placeholder] ||= I18n.t("avo.choose_an_option")

        super(id, **args, &block)

        @options_from_args = if args[:options].is_a? Hash
          ActiveSupport::HashWithIndifferentAccess.new args[:options]
        else
          args[:options]
        end
        @enum = args[:enum].present? ? args[:enum] : nil
        @display_value = args[:display_value].present? ? args[:display_value] : false
      end

      def options_for_select
        return options if options.is_a?(Array)

        if enum.present?
          return enum.invert if display_value
          return enum.map { |label, value| [label, label] }.to_h
        end

        display_value ? options.values : options
      end

      def label
        return value if options.is_a?(Array)

        if enum.present?
          return enum[value] if display_value
          return value
        end

        display_value ? value : options.invert[value]
      end

      private
      def options
        @options ||= if options_from_args.respond_to? :call
          options_from_args.call model: model, resource: resource, view: view, field: self
        else
          options_from_args
        end
      end
    end
  end
end
