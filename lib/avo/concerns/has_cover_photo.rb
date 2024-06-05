# Adds the ability to set the visibility of an item in the execution context.
module Avo
  module Concerns
    module HasCoverPhoto
      extend ActiveSupport::Concern

      class_methods do
        # Add class property to capture the settings
        attr_accessor :cover_photo
      end

      # Add instance property to compute the options
      def cover_photo
        Avo::CoverPhoto.new resource: self
      end
    end
  end
end
