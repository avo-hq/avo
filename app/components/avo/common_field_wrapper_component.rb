# frozen_string_literal: true

class Avo::CommonFieldWrapperComponent < ViewComponent::Base
  def initialize(field: nil, dash_if_blank: true, full_width: false, displayed_in_modal: false, form: nil, resource: {}, label: nil, view: nil, **args)
    @field = field
    @dash_if_blank = dash_if_blank
    @classes = args[:class].present? ? args[:class] : ""
    @args = args
    @displayed_in_modal = displayed_in_modal
    @form = form
    @resource = resource
    @model = resource.present? ? resource.model : nil
    @full_width = full_width
    @label = label
    @view = view
  end

  def label
    @label || @field.name
  end

  def stimulus_target
    "#{@field.id.to_s.underscore}_#{@field.type.to_s.underscore}_wrapper".camelize(:lower)
  end
end
