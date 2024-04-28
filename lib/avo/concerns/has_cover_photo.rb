# Adds the ability to set the visibility of an item in the execution context.
module Avo
  module Concerns
    module HasCoverPhoto
      extend ActiveSupport::Concern

      class_methods do
        attr_accessor :cover_photo
      end

      def cover_photo_value
        if self.class.cover_photo.is_a?(Symbol)
          record.send(self.class.cover_photo)
        elsif self.class.cover_photo.respond_to?(:call)
          Avo::ExecutionContext.new(target: self.class.cover_photo, record:, resource: self, view:).handle
        end
      end
    end
  end
end
