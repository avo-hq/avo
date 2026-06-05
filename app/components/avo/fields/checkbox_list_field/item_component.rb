# frozen_string_literal: true

class Avo::Fields::CheckboxListField::ItemComponent < Avo::BaseComponent
  prop :id
  prop :title
  prop :description, default: nil
  prop :image_url, default: nil
  prop :image_format, default: nil
  prop :image_alt, default: nil
  prop :name
  prop :checked, default: false
  prop :disabled, default: false
  prop :input_classes, default: nil
  prop :input_data, default: {}.freeze
  prop :input_html_id, default: nil
  prop :input_style, default: nil

  def row_data
    {
      "checkbox-list-field-target": "row",
      "checkbox-list-field-search-text": search_text
    }
  end

  def image_class
    rounding = case @image_format&.to_sym
    when :rounded then "rounded-sm"
    when :square then "rounded-none"
    else "rounded-full"
    end

    class_names("search-item-image", rounding)
  end

  def alt_text
    @image_alt || @title
  end

  def search_text
    [@title, @description].compact.join(" ")
  end
end
