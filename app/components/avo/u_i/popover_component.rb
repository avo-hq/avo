# frozen_string_literal: true

class Avo::UI::PopoverComponent < Avo::BaseComponent
  prop :id
  prop :classes
  prop :style
  prop :anchor
  prop :data, default: {}.freeze

  renders_one :header
  renders_one :body
  renders_one :footer

  def body_content
    body? ? body : content
  end

  def computed_style
    @computed_style ||= begin
      parts = []
      parts << "position-anchor: --#{@anchor}" if @anchor.present?
      parts << @style.to_s.strip.sub(/;\s*\z/, "") if @style.present?
      parts.join("; ").strip.presence
    end
  end
end
