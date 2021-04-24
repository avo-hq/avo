module Avo
  module Fields
    class DateTimeField < DateField
      attr_reader :format
      attr_reader :time_24hr
      attr_reader :timezone

      def initialize(id, **args, &block)
        super(id, **args, &block)

        @picker_format = args[:picker_format].present? ? args[:picker_format] : "Y-m-d H:i:S"
        @time_24hr = args[:time_24hr].present? ? args[:time_24hr] : false
        @timezone = args[:timezone].present? ? args[:timezone] : Rails.application.config.time_zone
      end

      def formatted_value
        return nil if value.nil?

        if @format.is_a?(Symbol)
          value.to_time.in_time_zone(timezone).to_s(@format)
        else
          value.to_time.in_time_zone(timezone).strftime(@format)
        end
      end

      def fill_field(model, key, value)
        if value.nil?
          model[id] = nil

          return model
        end

        return model if value.blank?

        model[id] = value.to_time.in_time_zone(Rails.application.config.time_zone)

        model
      end
    end
  end
end
