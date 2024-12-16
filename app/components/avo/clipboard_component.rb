# frozen_string_literal: true

class Avo::ClipboardComponent < Avo::BaseComponent
  prop :value

  def before_render
    @duration_value = 2500
    @content_value = helpers.svg("heroicons/outline/clipboard-document-check", class: "h-4 inline").gsub("\"", "'")
  end

  def render?
    @value.present?
  end
end
