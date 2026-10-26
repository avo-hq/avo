# frozen_string_literal: true

class Avo::BreadcrumbElementComponent < Avo::BaseComponent
  prop :text
  prop :url, default: nil
  prop :icon, default: nil
  prop :initials, default: nil
  prop :avatar
  # Resource color: tints the initials chip, same palette as the sidebar icon.
  prop :color, default: nil do |value|
    next nil if value.blank?
    value = value.to_sym if value.respond_to?(:to_sym)
    Avo::Sidebar::LinkComponent::PALETTE_COLORS.include?(value) ? value : nil
  end

  def color_class
    "breadcrumb-element--color-#{@color}" if @color.present?
  end

  def link?
    @url.present?
  end

  def wrapper_element(args = {}, &block)
    if link?
      link_to @url, **args, &block
    else
      content_tag :span, **args, &block
    end
  end
end
