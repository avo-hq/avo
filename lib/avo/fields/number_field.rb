module Avo
  module Fields
    class NumberField < TextField
      unless defined?(FORMATTERS)
        FORMATTERS = {
          delimited: :number_with_delimiter,
          currency: :number_to_currency,
          percentage: :number_to_percentage,
          human: :number_to_human
        }.freeze
      end

      attr_reader :min
      attr_reader :max
      attr_reader :step
      attr_reader :format

      def initialize(id, **args, &block)
        super

        @min = args[:min].present? ? args[:min].to_f : nil
        @max = args[:max].present? ? args[:max].to_f : nil
        @step = args[:step].present? ? args[:step].to_f : nil
        @format = args[:format]&.to_sym

        return if @format.nil? || FORMATTERS.key?(@format)

        raise ArgumentError, "Invalid number format: #{@format.inspect}. Valid formats are: #{FORMATTERS.keys.join(", ")}"
      end

      def table_header_class
        return super if format.blank?

        "#{super} text-end".strip
      end

      private

      def default_format_value(value)
        return value unless @view.display? && format.present?

        helper = FORMATTERS.fetch(format)
        options = formatter_options

        execute_context(-> { public_send(helper, value, **options) }, value:)
      end

      def formatter_options
        case format
        when :currency
          {unit: Avo.configuration.currency}
        when :percentage
          {strip_insignificant_zeros: true}
        else
          {}
        end
      end
    end
  end
end
