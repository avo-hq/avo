# frozen_string_literal: true

class Avo::UI::PopoverComponent < Avo::BaseComponent
  prop :classes
  prop :data, default: {}.freeze
  prop :open, default: false

  renders_one :header
  renders_one :body
  renders_one :footer

  def body_content
    body? ? body : content
  end
end
