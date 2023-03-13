# frozen_string_literal: true

module Avo
  module Fields
    class LocationField < TextField
      attr_reader :latitude, :longitude, :coordinates

      def initialize(id, **args, &block)
        super(id, **args, &block)

        @coordinates = args[:coordinates].present? ? args[:coordinates].to_f : nil
        @latitude = args[:latitude].present? ? args[:latitude].to_f : nil
        @longitude = args[:longitude].present? ? args[:longitude].to_f : nil
      end
    end
  end
end
