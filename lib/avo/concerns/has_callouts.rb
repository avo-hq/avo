module Avo
  module Concerns
    module HasCallouts
      extend ActiveSupport::Concern

      included do
        class_attribute :callouts, instance_accessor: false
      end

      def callouts
        ::Avo::Callouts.new resource: self
      end
    end
  end
end
