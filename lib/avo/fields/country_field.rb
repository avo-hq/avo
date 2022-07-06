module Avo
  module Fields
    class CountryField < BaseField
      include Avo::Fields::FieldExtensions::HasIncludeBlank

      attr_reader :countries
      attr_reader :display_code

      def initialize(id, **args, &block)
        args[:placeholder] ||= I18n.t("avo.choose_a_country")

        super(id, **args, &block)

        @countries = ISO3166::Country.translations.sort_by { |code, name| name }.to_h
        @display_code = args[:display_code].present? ? args[:display_code] : false
      end

      def select_options
        if @display_code
          countries.map do |code, name|
            [code, code]
          end
        else
          countries.map do |code, name|
            [name, code]
          end
        end
      end
    end
  end
end
