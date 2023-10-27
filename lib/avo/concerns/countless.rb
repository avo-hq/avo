module Avo
  module Concerns
    module Countless
      extend ActiveSupport::Concern

      included do
        class_attribute :countless, default: false
      end

      def countless?
        @countless ||= Avo::ExecutionContext.new(
          target: self.class.countless,
          resource: self,
          view: @view
        ).handle
      end
    end
  end
end
