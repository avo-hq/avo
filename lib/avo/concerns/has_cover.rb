# Adds the ability to set the visibility of an item in the execution context.
module Avo
  module Concerns
    module HasCover
      extend ActiveSupport::Concern

      class_methods do
        # Add class property to capture the settings
        attr_accessor :cover
      end

      # Add instance property to compute the options
      def cover
        Avo::Cover.new resource: self
      end
    end
  end
end
