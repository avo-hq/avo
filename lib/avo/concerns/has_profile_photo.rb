# Adds the ability to set the visibility of an item in the execution context.
module Avo
  module Concerns
    module HasProfilePhoto
      extend ActiveSupport::Concern

      class_methods do
        attr_accessor :profile_photo
      end

      def profile_photo_value
        if self.class.profile_photo.is_a?(Symbol)
          record.send(self.class.profile_photo)
        elsif self.class.profile_photo.respond_to?(:call)
          Avo::ExecutionContext.new(target: self.class.profile_photo, record:, resource:, view:).handle
        end
      end
    end
  end
end
