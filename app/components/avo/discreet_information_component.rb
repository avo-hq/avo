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
  prop :title
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

  def wrapper_element(args = {}, &block)
    if @url.present?
      link_to @url, **args, target: @target, &block
    else
      tag.div(**args, &block)
    end
  end
end
