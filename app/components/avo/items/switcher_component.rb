# frozen_string_literal: true

class Avo::Items::SwitcherComponent < Avo::BaseComponent
  include Turbo::FramesHelper

  attr_reader :resource
  attr_reader :reflection
  attr_reader :index
  attr_reader :item
  attr_reader :view

  def initialize(
    resource: nil,
    reflection: nil,
    item: nil,
    index: nil,
    view: nil,
    form: nil,
    parent_resource: nil,
    parent_record: nil,
    parent_component: nil,
    actions: nil,
    field_component_extra_args: {}
  )
    @resource = resource
    @reflection = reflection
    @form = form
    @index = index
    @item = item
    @view = view
    @parent_resource = parent_resource
    @parent_record = parent_record
    @parent_component = parent_component
    @actions = actions
    @field_component_extra_args = field_component_extra_args
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

  def tab_group_component
    Avo::TabGroupComponent.new resource: @resource, group: item.hydrate(view: view), index: index, params: params, form: form, view: view
  end

  def field_component
    final_item = item.dup.hydrate(resource: @resource, record: @resource.record, user: resource.user, view: view)
    final_item.component_for_view(@view).new(field: final_item, resource: @resource, index: index, form: form, **@field_component_extra_args)
  end

  def panel_component
    Avo::Items::PanelComponent.new(
      actions: @actions,
      form: form,
      index: index,
      is_main_panel: item.is_main_panel?,
      item: item.hydrate(view: view),
      parent_component: @parent_component,
      parent_record: @parent_record,
      parent_resource: @parent_resource,
      reflection: @reflection,
      resource: @resource,
      view: view
    )
  end
end
