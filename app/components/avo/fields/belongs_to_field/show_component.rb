# frozen_string_literal: true

class Avo::Fields::BelongsToField::ShowComponent < Avo::Fields::ShowComponent

  def target
    @field.inside_tab ? "_top" : nil
  end

end
