# frozen_string_literal: true

class Avo::Index::FieldWrapperComponent < ViewComponent::Base
  def initialize(field: nil, dash_if_blank: true, classes: '', **args)
    @field = field
    @dash_if_blank = dash_if_blank
    @classes = classes
    @args = args
  end
end
