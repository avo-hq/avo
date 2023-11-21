# Adds the ability to set the visibility of an item in the execution context.
module Avo
  module Concerns
    module HasDescription
      extend ActiveSupport::Concern

      class_methods do
        attr_accessor :description
      end

      def description
        Avo::ExecutionContext.new(target: @description || self.class.description, **description_attributes).handle
      end

      private

      # Override this method to add custom attributes to the description execution context.
      def description_attributes
        {}
      end
    end
  end
end
