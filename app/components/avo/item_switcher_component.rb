# frozen_string_literal: true

class Avo::ItemSwitcherComponent < Avo::BaseComponent
  include Turbo::FramesHelper

  attr_reader :item
  attr_reader :view
  attr_reader :index
  attr_reader :resource

  def initialize(resource: nil, item: nil, index: nil, view: nil)
    @item = item
    @view = view
    @index = index
    @resource = resource
  end
end
