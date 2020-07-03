require_relative 'field'

module Avocado
  module Fields
    class CountryField < Field
      def initialize(name, **args, &block)
        @defaults = {
          sortable: true,
          component: 'country-field',
        }

        super(name, **args, &block)

        @countries = ISO3166::Country.translations
        @display_name = args[:display_name].present? ? args[:display_name] : false
      end

      def hydrate_field(fields, model, resource, view)
        {
          countries: @countries,
          display_name: @display_name
        }
      end
    end
  end
end
