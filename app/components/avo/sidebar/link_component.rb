# frozen_string_literal: true

class Avo::Sidebar::LinkComponent < ViewComponent::Base
  attr_reader :active
  attr_reader :target
  attr_reader :label
  attr_reader :path
  attr_reader :data
  attr_reader :icon

  def initialize(label: nil, path: nil, active: :inclusive, target: nil, data: {}, icon: nil)
    @label = label
    @path = path
    @active = active
    @target = target
    @data = data
    @icon = icon
  end

  def is_external?
    # If the path contains the scheme, check if it includes the root path or not
    return !path.include?(Avo::App.root_path) if URI(path).scheme.present?

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
