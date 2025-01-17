module Avo
  module Concerns
    module HasDiscreetInformation
      extend ActiveSupport::Concern
      include ActionView::Helpers::SanitizeHelper

      included do
        class << self
          attr_accessor :discreet_information
        end
      end

      def discreet_information
        Avo::DiscreetInformation.new resource: self
      end
    end
  end
end
