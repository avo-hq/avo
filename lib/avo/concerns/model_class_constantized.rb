module Avo
  module Concerns
    module ModelClassConstantized
      extend ActiveSupport::Concern

      class_methods do
        attr_reader :model_class

        # Cast the model class to a constantized version and memoize it like that
        def model_class=(value)
          @model_class = case value
          when Class
            value
          when String, Symbol
            value.to_s.safe_constantize
          else
            raise ArgumentError.new "Failed to find a proper model class for #{self.to_s}"
          end
        end
      end
    end
  end
end
