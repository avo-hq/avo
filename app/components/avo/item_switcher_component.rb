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

    return false if item.is_main_panel?

    true
  end

  def in_reflection?
    @reflection.present?
  end

  def tab_group_component
    Avo::TabGroupComponent.new resource: @resource, group: item.hydrate(view: view), index: index, params: params, form: form, view: view, tabs_style: item.style
  end

  def field_component
    item.component_for_view(@view).new(field: item.hydrate(resource: @resource, view: @view, model: @resource.model), resource: @resource, index: index, form: form)
  end
end
