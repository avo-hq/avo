module Avo
  module Fields
    class CountryField < BaseField
      include Avo::Fields::FieldExtensions::HasIncludeBlank

      attr_reader :countries
      attr_reader :display_code


      class_attribute :supported_options, default: {}
      Avo::Fields::COMMON_OPTIONS.each do |common_option, hash|
        supports common_option, hash
      end

      def initialize(id, **args, &block)
        args[:placeholder] ||= I18n.t("avo.choose_a_country")

        super(id, **args, &block)

        @countries = begin
          ISO3166::Country.translations.sort_by { |code, name| name }.to_h
        rescue
          {none: "You need to install the countries gem for this field to work properly"}
        end
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

      def options_for_filter
        select_options
      end
    end
  end
end
