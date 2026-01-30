# frozen_string_literal: true

class Avo::ClipboardComponent < Avo::BaseComponent
  prop :value

  def before_render
    @duration_value = 2500
    @content_value = helpers.svg("tabler/outline/clipboard-check", class: "h-4 inline").tr('"', "'")
  end

  def render?
    @value.present?
  end
end
