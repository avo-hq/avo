# Adds the ability to set the visibility of an item in the execution context.
module Avo
  module Concerns
    module IsVisible
      attr_accessor :visible

      def visible?
        # Default to true
        return true if visible.nil?

        Avo::ExecutionContext.new(target: visible, resource: @resource).handle
      end
    end
  end
end
