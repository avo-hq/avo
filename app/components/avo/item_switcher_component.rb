# frozen_string_literal: true

class Avo::ItemSwitcherComponent < Avo::BaseComponent
  include Turbo::FramesHelper

  attr_reader :resource
  attr_reader :index
  attr_reader :item
  attr_reader :view

  def initialize(resource: nil, item: nil, index: nil, view: nil, form: nil)
    @resource = resource
    @form = form
    @index = index
    @item = item
    @view = view
  end

  def form
    @form || nil
  end
end
