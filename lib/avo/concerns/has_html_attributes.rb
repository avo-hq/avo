module Avo
  module Concerns
    module HasHtmlAttributes
      extend ActiveSupport::Concern

      included do
      end

      class_methods do
      end

      attr_reader :html

      def data_attributes
        html.dig(:data) || {}
      end
    end
  end
end
