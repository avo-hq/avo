# Adds the ability to set the visibility of an item in the execution context.
module Avo
  module Concerns
    module HasCoverPhoto
      extend ActiveSupport::Concern

      class_methods do
        attr_accessor :cover_photo
      end

      def cover_photo_size
        self.class&.cover_photo&.fetch(:size) || :md
      end

      def cover_photo_value
        return unless self.class&.cover_photo&.fetch(:source).present?

        if self.class.cover_photo[:source].is_a?(Symbol)
          record.send(self.class.cover_photo[:source])
        elsif self.class.cover_photo[:source].respond_to?(:call)
          Avo::ExecutionContext.new(target: self.class.cover_photo[:source], record:, resource: self, view:).handle
        end
      end
    end
  end
end
