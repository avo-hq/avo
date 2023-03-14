# frozen_string_literal: true

module Avo
  module Fields
    class LocationField < BaseField
      def initialize(id, **args, &block)
        super(id, **args, &block)
      end
    end
  end
end
