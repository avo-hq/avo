require_relative 'field'

module Avocado
  module Fields
    class CountryField < Field
      def initialize(name, **args, &block)
        @defaults = {
          sortable: true,
          component: 'country-field',
          placeholder: 'Choose a country',
        }

        super(name, **args, &block)

        @countries = ISO3166::Country.translations.sort_by { |code, name| name }.to_h
        @display_code = args[:display_code].present? ? args[:display_code] : false
      end

      def hydrate_field(fields, model, resource, view)
        if [:show, :index].include? view
          # Just return the DB code.
          return {} if @display_code

          # Compute and get the translated value.
          return {
            value: @countries[fields[:value]],
          }
        end

        {
          countries: @countries,
          display_code: @display_code
        }
      end
    end
  end
end
