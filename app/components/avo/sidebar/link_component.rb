# frozen_string_literal: true

class Avo::Sidebar::LinkComponent < ViewComponent::Base
  attr_reader :active
  attr_reader :target
  attr_reader :label
  attr_reader :path

  def initialize(label: nil, path: nil, active: :inclusive, target: nil)
    @label = label
    @path = path
    @active = active
    @target = target
  end

  def is_external?
    URI(path).scheme.present?
  end

  # For external links active_link_to marks them all as active.
  def link_method
    is_external? ? :link_to : :active_link_to
  end

  def classes
    "px-4 flex-1 flex mx-6 leading-none py-2 text-black rounded font-medium hover:bg-gray-150"
  end
end
