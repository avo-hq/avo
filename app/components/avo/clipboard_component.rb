# frozen_string_literal: true

class Avo::ClipboardComponent < Avo::BaseComponent
  prop :value
  prop :view, default: "index"
  def render?
    @value.present?
  end

  private

  def text_value
    (@view == "show") ? "Copy to clipboard" : ""
  end

  def success_value
    (@view == "show") ? "Copied" : "✔"
  end
end
