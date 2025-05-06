module Avo
  module Fields
    module Concerns
      module DomId
        extend ActiveSupport::Concern

        class_methods do
          def param_key = to_s.underscore
        end

        def to_key = [@id]

        def model_name = self.class
      end
    end
  end
end
