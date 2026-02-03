# Adds the ability to set the visibility of an item in the execution context.
module Avo
  module Concerns
    module HasClasses
      extend ActiveSupport::Concern

      class_methods do
        attr_accessor :classes
      end

      def classes(additional_attributes = {})
        Avo::ExecutionContext.new(
          target: @classes || self.class.classes,
          **additional_attributes
        ).handle
      end
    end
  end
end
