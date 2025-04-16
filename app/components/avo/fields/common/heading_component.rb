# frozen_string_literal: true

class Avo::Fields::Common::HeadingComponent < Avo::BaseComponent
  include Avo::Concerns::HasResourceStimulusControllers

  prop :field

  def after_initialize
    @view = @field.resource.view
    @classes = "flex items-start py-1 leading-tight bg-gray-100 text-gray-500 text-xs #{@field.get_html(:classes, view: @view, element: :wrapper)}"
    @data = {**stimulus_data_attributes, **@field.get_html(:data, view: @view, element: :wrapper)}
    add_stimulus_attributes_for(@field.resource, @data)
  end
end
