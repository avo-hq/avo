module Avo
  module Fields
    class CurrencyField < BaseField
      attr_reader :currency
      attr_reader :locale

      def initialize(id, **args, &block)
        super(id, **args, &block)

        @currency = args[:currency].present? ? args[:currency].to_s : Avo.configuration.currency
        @locale = args[:locale].present? ? args[:locale].to_s : Avo.configuration.locale
      end
    end
  end
end
