module Avo
  module Concerns
    module PagyCompatibility
      extend ActiveSupport::Concern

      included do
        if defined?(::Pagy::Method)
          include ::Pagy::Method
        else
          include ::Pagy::Backend
        end
      end

      private

      def pagy_v43_or_newer?
        defined?(::Pagy::VERSION) && ::Gem::Version.new(::Pagy::VERSION) >= ::Gem::Version.new("43.0")
      end
    end
  end
end
