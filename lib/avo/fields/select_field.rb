module Avo
  module Fields
    class SelectField < BaseField
      attr_reader :options
      attr_reader :enum
      attr_reader :display_value

      def initialize(name, **args, &block)
        @defaults = {
          partial_name: "select-field"
        }

        super(name, **args, &block)

        @options = args[:options].present? ? args[:options] : args[:enum]
        @options = ActiveSupport::HashWithIndifferentAccess.new @options
        @enum = args[:enum].present? ? args[:enum] : nil
        @display_value = args[:display_value].present? ? args[:display_value] : false
        @placeholder = args[:placeholder].present? ? args[:placeholder].to_s : I18n.t("avo.choose_an_option")
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
        if display_value
          value
        elsif enum.present?
          options[value]
        else
          options.invert[value]
        end
      end
    end
  end
end
