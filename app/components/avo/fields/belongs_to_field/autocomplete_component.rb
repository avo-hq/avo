# frozen_string_literal: true

class Avo::Fields::BelongsToField::AutocompleteComponent < ViewComponent::Base
  def initialize(form:, field:, type: nil, model_key:, foreign_key:)
    @form = form
    @field = field
    @type = type
    @model_key = model_key
    @foreign_key = foreign_key
  end
end
