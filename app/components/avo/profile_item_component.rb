# frozen_string_literal: true

class Avo::ProfileItemComponent < ViewComponent::Base
  attr_reader :label
  attr_reader :icon
  attr_reader :path
  attr_reader :active
  attr_reader :target
  attr_reader :method
  attr_reader :params
  attr_reader :classes

  def initialize(label: nil, icon: nil, path: nil, active: :inclusive, target: nil, title: nil, method: nil, params: {}, classes: "")
    @label = label
    @icon = icon
    @path = path
    @active = active
    @target = target
    @title = title
    @method = method
    @params = params
    @classes = classes
  end

  def title
    @title || @label
  end

  private

  def button_classes
    "flex-1 flex items-center justify-center bg-white text-left cursor-pointer text-gray-800 font-semibold hover:bg-primary-100 block px-4 py-1 w-full py-3 text-center rounded w-full"
  end
end
