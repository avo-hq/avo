# frozen_string_literal: true

require "view_component/version"

# A single sidebar link (leaf). `variant: :default` or `:subitem`. Knows nothing
# about menus; callers pass the path, label and resolved `active` (a match mode
# like :inclusive, or a boolean to force it).
class Avo::Sidebar::LinkComponent < Avo::BaseComponent
  prop :label
  prop :path
  prop :active, default: :inclusive do |value|
    value.is_a?(String) ? value.to_sym : value
  end
  prop :target do |value|
    value&.to_sym
  end
  prop :data, default: {}.freeze
  prop :icon
  prop :reserve_icon_space, default: false
  prop :args, kind: :**, default: {}.freeze
  prop :hotkey, default: nil
  prop :variant, default: :default
  prop :bar_class, default: ""

  def subitem?
    @variant == :subitem
  end

  def root_css_class
    return "sidebar-link" unless subitem?

    ["sidebar-subitem", @bar_class].reject(&:blank?).join(" ")
  end

  # Sub-items don't show icons (for now); top-level links do.
  def show_icon?
    return false if subitem?

    @reserve_icon_space || link_icon.present?
  end

  def link_data
    return @data if @hotkey.blank?

    @data.merge(hotkey: @hotkey)
  end

  def is_external?
    uri = URI(@path)
    # Paths without a scheme are always internal (relative app paths).
    return false if uri.scheme.blank?

    # A link with a scheme is internal only when its path is mounted under Avo.
    # Compare against the URI path component, not the whole URL string, otherwise
    # hosts like "avohq.io" falsely match a "/avo" mount path (via "//avohq.io").
    # Use root_path_without_url so prefix_path + mount_path setups are recognized.
    !uri.path.start_with?(helpers.root_path_without_url)
  rescue URI::InvalidURIError
    true
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

  def link_icon
    @icon
  end
end
