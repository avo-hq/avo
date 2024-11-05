# frozen_string_literal: true

class Avo::Fields::ComboboxField::EditComponent < Avo::Fields::EditComponent
  def name_when_new
    if @field.accept_free_text
     "#{@resource.form_scope}[#{@field.for_attribute}]"
    end
  end
end
