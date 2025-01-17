module Avo
  module Concerns
    module HasDiscreetInformation
      extend ActiveSupport::Concern

      included do
        class_attribute :discreet_information, instance_accessor: false
      end

      def discreet_information
        ::Avo::DiscreetInformation.new resource: self
      end
    end
  end
end
