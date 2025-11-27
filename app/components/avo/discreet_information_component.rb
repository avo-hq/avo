# frozen_string_literal: true

# TODO: support url and target
class Avo::DiscreetInformationComponent < Avo::BaseComponent
  prop :icon
  # if as is :badge, this gets added with a darker bg
  prop :key
  prop :text
  # as: :icon, :text, :badge, :key_value
  prop :as, default: :text
  prop :url
  prop :target
  prop :tooltip
  prop :data

  def as_icon?
    @as == :icon
  end

  def as_text?
    @as == :text
  end

  def as_badge?
    @as == :badge
  end

  def as_key_value?
    @as == :key_value
  end
end

