# frozen_string_literal: true

class Avo::Fields::Common::HeadingComponent < ViewComponent::Base
  include Avo::Concerns::HasResourceStimulusControllers

  def initialize(field:)
    @field = field
    @view = field.resource.view

    @data = stimulus_data_attributes
    add_stimulus_attributes_for(field.resource, @data)
  end
end
