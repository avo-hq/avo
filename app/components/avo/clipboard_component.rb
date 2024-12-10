# frozen_string_literal: true

class Avo::ClipboardComponent < Avo::BaseComponent
  prop :value

  def render?
    @value.present?
  end
end
