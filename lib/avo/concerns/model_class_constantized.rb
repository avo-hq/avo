module Avo
  module Concerns
    module ModelClassConstantized
      extend ActiveSupport::Concern

      class_methods do
        # Cast the model class to a constantized version and memoize it like that
        def model_class=(value)
          @model_class = value
        end
      end
    end
  end
end
