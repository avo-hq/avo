# frozen_string_literal: true

require "view_component/version"

class Avo::Sidebar::LinkComponent < Avo::BaseComponent
  TYPES = %i[item group sub_item].freeze

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
  prop :type, default: :item do |value|
    value&.to_sym
  end
  prop :disabled, default: false
  prop :counter
  prop :actions, default: false
  prop :args, kind: :**, default: {}.freeze

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

  def item?
    @type == :item
  end

  def group?
    @type == :group
  end

  def sub_item?
    @type == :sub_item
  end

  def show_counter?
    @counter.present?
  end

  def wrapper_classes
    class_names(
      "navigation-item",
      @args[:class],
      "navigation-item--item": item?,
      "navigation-item--group": group?,
      "navigation-item--sub-item": sub_item?,
      "navigation-item--disabled": @disabled
    )
  end

  def wrapper_element(**args, &block)
    merged = args.merge(class: wrapper_classes)
    if @path.present? && !@disabled
      link_caller.send(link_method, @path, **merged, &block)
    else
      tag.div(**merged.except(:active, :active_class, :target), &block)
    end
  end
end
