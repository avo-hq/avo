module Avo
  module Concerns
    module AbstractResource
      extend ActiveSupport::Concern

      class_methods do
        def abstract_resource! = @abstract_resource = true
        def is_abstract? = @abstract_resource == true
      end
    end
  end
end
