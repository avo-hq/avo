# frozen_string_literal: true

class Avo::Fields::BelongsToField::AutocompleteComponent < ViewComponent::Base
  def initialize(form:, field:, type: nil, model_key:, foreign_key:)
    @form = form
    @field = field
    @type = type
    @model_key = model_key
    @foreign_key = foreign_key
  end

  def field_label
    if searchable?
      @field.value&.class == @type ? @field.field_label : nil
    else
      @field.field_label
    end
  end

  def field_value
    if searchable?
      @field.value&.class == @type ? @field.field_value : nil
    else
      @field.field_value
    end
  end

  private

  def searchable?
    @type.present?
  end
end
