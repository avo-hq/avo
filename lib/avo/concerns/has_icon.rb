# Adds the ability to set the visibility of an item in the execution context.
module Avo
  module Concerns
    module HasIcon
      extend ActiveSupport::Concern

      class_methods do
        attr_accessor :icon
      end

      def icon(additional_attributes = {})
        Avo::ExecutionContext.new(
          target: @icon || self.class.icon,
          resource: self,
          record: @record
        ).handle
      end
    end
  end
end
