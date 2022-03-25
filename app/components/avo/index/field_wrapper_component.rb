# frozen_string_literal: true

class Avo::Index::FieldWrapperComponent < ViewComponent::Base
  def initialize(field: nil, dash_if_blank: true, center_content: false, **args)
    @field = field
    @dash_if_blank = dash_if_blank
    @center_content = center_content
    @classes = args[:class].present? ? args[:class] : ""
    @args = args
  end
end
