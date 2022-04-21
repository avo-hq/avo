# frozen_string_literal: true

class Avo::Fields::TagsField::ShowComponent < Avo::Fields::ShowComponent
  def label_from_item(item)
    if @field.acts_as_taggable_on.present?
      item['value']
    else
      item
    end
  end
end
