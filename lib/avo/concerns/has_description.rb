# Adds the ability to set the visibility of an item in the execution context.
module Avo
  module Concerns
    module HasDescription
      extend ActiveSupport::Concern

      class_methods do
        attr_accessor :description
        attr_accessor :discreet_description
      end

      def description(additional_attributes = {})
        Avo::ExecutionContext.new(
          target: @description || self.class.description,
          **description_attributes,
          **additional_attributes
        ).handle
      end

      def discreet_description(additional_attributes = {})
        Avo::ExecutionContext.new(
          target: @discreet_description || self.class.discreet_description,
          **description_attributes,
          **additional_attributes
        ).handle
      end

      private

      # Override this method to add custom attributes to the description execution context.
      def description_attributes
        {}
      end
    end
  end
end
