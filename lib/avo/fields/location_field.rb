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

      def as_lat_long?
        stored_as.is_a?(Array) && stored_as.count == 2
      end

      def as_lat_long_id(get: nil)
        if get == :lat
          "#{id}[#{stored_as.first}]"
        elsif get == :long
          "#{id}[#{stored_as.last}]"
        end
      end

      def as_lat_long_value(get: nil)
        if get == :lat
          model.send(stored_as.first)
        elsif get == :long
          model.send(stored_as.last)
        end
      end

      def fill_field(model, key, value, params)
        if as_lat_long?
          latitude_field, longitude_field = stored_as
          model.send("#{latitude_field}=", value[latitude_field])
          model.send("#{longitude_field}=", value[longitude_field])
          model
        else
          super(model, key, value.split(","), params)
        end
      end

      def to_permitted_param
        if as_lat_long?
          [:"#{id}", "#{id}": {}]
        else
          super
        end
      end
    end
  end
end
