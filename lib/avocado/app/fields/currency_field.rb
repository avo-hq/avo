require_relative 'field'

module Avocado
  module Fields
    class CurrencyField < Field
      def initialize(name, **args, &block)
        @defaults = {
          sortable: true,
          component: 'currency-field',
          computable: true,
        }

        super(name, **args, &block)

        @currency = args[:currency].present? ? args[:currency].to_s : Avocado.configuration.currency
        @locale = args[:locale].present? ? args[:locale].to_s : Avocado.configuration.locale
      end

      def hydrate_resource(model, resource, view)
        {
          currency: @currency,
          locale: @locale,
        }
      end
    end
  end
end
