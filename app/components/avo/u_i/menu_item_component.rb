# frozen_string_literal: true

class Avo::UI::MenuItemComponent < Avo::BaseComponent
  VALID_TYPES = %i[default action header].freeze unless defined?(VALID_TYPES)

  prop :type, default: :default do |value|
    normalized = value.to_s.to_sym
    VALID_TYPES.include?(normalized) ? normalized : :default
  end

  prop :icon
  prop :label, default: "Menu item"
  prop :url
  prop :size, default: :medium
  prop :disabled, default: false

  def action?
    @type == :action
  end

  def header?
    @type == :header
  end

  def wrapper_tag
    @url.present? && !@disabled ? :a : :div
  end

  def wrapper_options
    options = {}
    options[:href] = @url if @url.present? && !@disabled
    options
  end
end
