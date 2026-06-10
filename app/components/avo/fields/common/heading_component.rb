# frozen_string_literal: true

class Avo::Fields::Common::HeadingComponent < Avo::BaseComponent
  include Avo::Concerns::HasResourceStimulusControllers

  prop :field

  def after_initialize
    @view = @field.resource.view
    @classes = "flex items-start leading-tight bg-background text-content-secondary font-medium text-xs py-2 px-4 h-full w-full #{@field.get_html(:classes, view: @view, element: :wrapper)}"
    @data = {**stimulus_data_attributes, **@field.get_html(:data, view: @view, element: :wrapper)}
    add_stimulus_attributes_for(@field.resource, @data)
  end
end
