# frozen_string_literal: true

class Avo::ClipboardComponent < Avo::BaseComponent
  prop :value

  def render?
    @value.present?
  end

  private

  def success_value
    helpers.render('heroicons/outline/clipboard-document-check', class: 'h-4 inline')
  end
end
