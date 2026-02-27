# frozen_string_literal: true

require "view_component/version"

class Avo::Sidebar::LinkComponent < Avo::BaseComponent
  prop :label
  prop :path
  prop :active, default: :inclusive do |value|
    value&.to_sym
  end
  prop :target do |value|
    value&.to_sym
  end
  prop :data, default: {}.freeze
  prop :icon
  prop :args, kind: :**, default: {}.freeze
  prop :items

  def is_external?
    # If the path contains the scheme, check if it includes the root path or not
    return !@path.include?(helpers.mount_path) if URI(@path).scheme.present?

    false
  end

  # For external links active_link_to marks them all as active.
  def link_method
    is_external? ? :link_to : :active_link_to
  end

  # Backwards compatibility with ViewComponent 3.x
  def link_caller
    if Gem::Version.new(ViewComponent::VERSION::STRING) >= Gem::Version.new("4.0.0")
      helpers
    else
      self
    end
  end

  def parent_link_active?
    return false if @path.blank?
    helpers.is_active_link?(@path, @active)
  end
end
