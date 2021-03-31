# frozen_string_literal: true

class Avo::Index::FieldWrapperComponent < ViewComponent::Base
  def initialize(field: nil, dash_if_blank: true, **args)
    @field = field
    @dash_if_blank = dash_if_blank
    @classes = args[:class].present? ? args[:class] : ""
    @args = args
  end
end
