# frozen_string_literal: true

class Avo::ItemSwitcherComponent < Avo::BaseComponent
  include Turbo::FramesHelper

  attr_reader :resource
  attr_reader :reflection
  attr_reader :index
  attr_reader :item
  attr_reader :view

  def initialize(resource: nil, reflection: nil, item: nil, index: nil, view: nil, form: nil)
    @resource = resource
    @reflection = reflection
    @form = form
    @index = index
    @item = item
    @view = view
  end

  def form
    @form || nil
  end

  def render?
    # Stops rendering if the field should be hidden in reflections
    if item.is_field?
      return false if in_reflection? && item.hidden_in_reflection?
    end

    true
  end

  def in_reflection?
    @reflection.present?
  end
end
