module Avo
  module Resources
    class ArrayResource < Base
      extend ActiveSupport::DescendantsTracker

      include ActionView::Helpers::UrlHelper
      include Avo::Concerns::HasItems
      include Avo::Concerns::CanReplaceItems
      include Avo::Concerns::HasControls
      include Avo::Concerns::HasResourceStimulusControllers
      include Avo::Concerns::ModelClassConstantized
      include Avo::Concerns::HasDescription
      include Avo::Concerns::HasCoverPhoto
      include Avo::Concerns::HasProfilePhoto
      include Avo::Concerns::HasHelpers
      include Avo::Concerns::Hydration
      include Avo::Concerns::ControlsPlacement
      include Avo::Concerns::Pagination

      delegate :model_class, to: :class

      class << self


        # Returns the model class being used for this resource.
        #
        # The Resource instance has a model_class method too so it can support the STI use cases
        # where we figure out the model class from the record
        # def model_class(record_class: nil)
        #   # get the model class off of the static property
        #   return constantized_model_class if @model_class.present?

        #   # get the model class off of the record for STI models
        #   return record_class if record_class.present?

        #   # generate a model class
        #   class_name.safe_constantize
        # end

        def model_class
          ActiveSupport::OrderedOptions.new.tap do |obj|
            obj.model_name = ActiveSupport::OrderedOptions.new.tap do |thing|
              thing.plural = "Array"
              # thing.plural = "Array"
            end
            obj.column_names = [:id, :name, :release_date]
          end
        end
      end
    end
  end
end
