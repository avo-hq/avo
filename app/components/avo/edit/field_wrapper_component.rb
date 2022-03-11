# frozen_string_literal: true

class Avo::Edit::FieldWrapperComponent < ViewComponent::Base
  def initialize(field: nil, dash_if_blank: true, full_width: false, displayed_in_modal: false, form: nil, resource: {}, label: nil, **args)
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
  end
end
