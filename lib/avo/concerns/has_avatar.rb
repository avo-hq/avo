# Adds the ability to set the visibility of an item in the execution context.
module Avo
  module Concerns
    module HasAvatar
      extend ActiveSupport::Concern

      class_methods do
        # Add class property to capture the settings
        attr_accessor :avatar
      end

      # Add instance property to compute the options
      def avatar
        Avatar.new resource: self
      end

      def initials
        record_title.split(" ").map(&:first).join("").first(2).upcase
      end
    end
  end
end
