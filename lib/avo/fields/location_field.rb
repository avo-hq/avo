# frozen_string_literal: true

module Avo
  module Fields
    class LocationField < BaseField
      attr_reader :stored_as, :zoom

      def initialize(id, **args, &block)
        hide_on :index
        super(id, **args, &block)

        @stored_as = args[:stored_as].present? ? args[:stored_as] : nil # You can pass it an array of db columns [:latitude, :longitude]
        @zoom = args[:zoom].present? ? args[:zoom].to_i : 15
      end

      def value_as_array?
        stored_as.is_a?(Array) && stored_as.count == 2
      end

      def as_lat_long_field_id(get)
        if get == :lat
          stored_as.first
        elsif get == :long
          stored_as.last
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
          record.send(stored_as.first)
        elsif get == :long
          record.send(stored_as.last)
        end
      end

      def fill_field(record, key, value, params)
        if value_as_array?
          latitude_field, longitude_field = stored_as
          record.send("#{latitude_field}=", value[latitude_field])
          record.send("#{longitude_field}=", value[longitude_field])
          record
        else
          super(record, key, value.split(","), params)
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
          [@record.send(stored_as.first), @record.send(stored_as.last)]
        else
          super
        end
      end

      def value_present?
        return value.first.present? && value.second.present? if value.is_a?(Array) && value.count == 2

        value.present?
      end

      def assign_value(record:, value:)
        return super if stored_as.blank?

        stored_as.each_with_index do |database_id, index|
          record.send("#{database_id}=", value[index])
        end
      end
    end
  end
end
