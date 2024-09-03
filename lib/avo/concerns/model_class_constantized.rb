module Avo
  module Concerns
    module ModelClassConstantized
      extend ActiveSupport::Concern

      class_methods do
        # Cast the model class to a constantized version and memoize it like that
        def model_class=(value)
          @model_class = value
        end

        # Cast the model class to a constantized version
        def constantized_model_class
          @constantized_model_class ||= case @model_class
          when Class
            @model_class
          when String, Symbol
            @model_class.to_s.safe_constantize
          else
            raise ArgumentError.new "Failed to find a proper model class for #{self}"
          end
        end
      end
    end
  end
end
