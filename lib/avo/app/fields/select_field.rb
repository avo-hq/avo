module Avo
  module Fields
    class SelectField < Field
      def initialize(name, **args, &block)
        @defaults = {
          partial_name: 'select-field',
        }

        super(name, **args, &block)

        @options = args[:options].present? ? ActiveSupport::HashWithIndifferentAccess.new(args[:options]) : nil
        @display_with_value = args[:display_with_value].present? ? args[:display_with_value] : false
        @placeholder = args[:placeholder].present? ? args[:placeholder].to_s : I18n.t('avo.choose_an_option')
      end

      def hydrate_field(fields, model, resource, view)
        {
          options: @options,
          # enum: @enum,
          display_with_value: @display_with_value,
          placeholder: @placeholder,
        }
      end
    end
  end
end
