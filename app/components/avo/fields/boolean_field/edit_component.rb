# frozen_string_literal: true

class Avo::Fields::BooleanField::EditComponent < Avo::Fields::EditComponent
  delegate :as_toggle?, to: :@field

  def after_initialize
    @checkbox_id = "#{@field.id}_checkbox"
  end
end
