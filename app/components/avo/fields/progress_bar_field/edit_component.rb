# frozen_string_literal: true

class Avo::Fields::ProgressBarField::EditComponent < Avo::Fields::EditComponent
  def input_id
    "progress-bar-#{@field.id}"
  end
end
