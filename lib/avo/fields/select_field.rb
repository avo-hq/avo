module Avo
  module Fields
    class SelectField < BaseField
      attr_reader :options
      attr_reader :enum
      attr_reader :display_value

      def initialize(id, **args, &block)
        args[:placeholder] ||= I18n.t("avo.choose_an_option")

        super(id, **args, &block)

        options = args[:options].present? ? args[:options] : args[:enum]
        @options = ActiveSupport::HashWithIndifferentAccess.new options
        @enum = args[:enum].present? ? args[:enum] : nil
        @display_value = args[:display_value].present? ? args[:display_value] : false
      end

      def options_for_select
        if enum.present?
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
        if enum.present?
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
