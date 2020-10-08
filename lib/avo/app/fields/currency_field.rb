module Avo
  module Fields
    class CurrencyField < Field
      def initialize(name, **args, &block)
        @defaults = {
          sortable: true,
          component: 'currency-field',
          computable: true,
        }

        super(name, **args, &block)

        @currency = args[:currency].present? ? args[:currency].to_s : Avo.configuration.currency
        @locale = args[:locale].present? ? args[:locale].to_s : Avo.configuration.locale
      end

      def hydrate_field(fields, model, resource, view)
        {
          currency: @currency,
          locale: @locale,
        }
      end
    end
  end
end
