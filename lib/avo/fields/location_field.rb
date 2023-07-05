# frozen_string_literal: true

module Avo
  module Fields
    class LocationField < BaseField
      attr_reader :stored_as

      def initialize(id, **args, &block)
        hide_on :index
        super(id, **args, &block)

        @stored_as = args[:stored_as].present? ? args[:stored_as] : nil # You can pass it an array of db columns [:latitude, :longitude]
      end

      def value_as_array?
        stored_as.is_a?(Array) && stored_as.count == 2
      end

      def as_lat_long_field_id(get)
        if get == :lat
          "#{id}[#{stored_as.first}]"
        elsif get == :long
          "#{id}[#{stored_as.last}]"
        end
      end

      def as_lat_long_placeholder(get)
        if get == :lat
          "Enter #{stored_as.first}"
        elsif get == :long
          "Enter #{stored_as.last}"
        end
      end

      def as_lat_long_value(get)
        if get == :lat
          model.send(stored_as.first)
        elsif get == :long
          model.send(stored_as.last)
        end
      end

      def fill_field(model, key, value, params)
        if value_as_array?
          latitude_field, longitude_field = stored_as
          model.send("#{latitude_field}=", value[latitude_field])
          model.send("#{longitude_field}=", value[longitude_field])
          model
        else
          super(model, key, value.split(","), params)
        end
      end

      def to_permitted_param
        if value_as_array?
          [:"#{id}", "#{id}": {}]
        else
          super
        end
      end

      def value
        if value_as_array?
          [@model.send(stored_as.first), @model.send(stored_as.last)]
        else
          super
        end
      end

      def value_present?
        return value.first.present? && value.second.present? if value.is_a?(Array) && value.count == 2

        value.present?
      end
    end
  end
end
