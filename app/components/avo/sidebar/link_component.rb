# frozen_string_literal: true

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

  def is_external?
    # If the path contains the scheme, check if it includes the root path or not
    return !@path.include?(helpers.mount_path) if URI(@path).scheme.present?

    false
  end

  # For external links active_link_to marks them all as active.
  def link_method
    is_external? ? :link_to : :active_link_to
  end

  def classes
    "px-4 pr-0 flex-1 flex mx-6 leading-none py-2 text-black rounded font-medium hover:bg-gray-100 gap-1"
  end
end
