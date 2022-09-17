# frozen_string_literal: true

class Avo::Show::FieldWrapperComponent < ViewComponent::Base
  def initialize(field: nil, resource: nil, dash_if_blank: true, full_width: false, **args)
    @field = field
    @resource = resource
    @dash_if_blank = dash_if_blank
    @classes = args[:class].present? ? args[:class] : ""
    @args = args
    @full_width = full_width
  end
end
