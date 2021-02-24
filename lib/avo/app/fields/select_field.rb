module Avo
  module Fields
    class SelectField < Field
      attr_reader :options
      attr_reader :enum
      attr_reader :display_value

      def initialize(name, **args, &block)
        @defaults = {
          partial_name: 'select-field',
        }

        super(name, **args, &block)

        @options = args[:options].present? ? ActiveSupport::HashWithIndifferentAccess.new(args[:options]) : args[:enum]
        @enum = args[:enum].present? ? args[:enum] : nil
        @display_value = args[:display_value].present? ? args[:display_value] : false
        @placeholder = args[:placeholder].present? ? args[:placeholder].to_s : I18n.t('avo.choose_an_option')
      end

      def label
        if display_value
          options[value]
        else
          value
        end
      end
    end
  end
end
