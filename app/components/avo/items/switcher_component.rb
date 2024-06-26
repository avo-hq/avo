# frozen_string_literal: true

class Avo::Items::SwitcherComponent < Avo::BaseComponent
  include Turbo::FramesHelper

  prop :resource, _Nilable(Avo::BaseResource), reader: :public
  prop :reflection, _Nilable(ActiveRecord::Reflection::AssociationReflection)
  prop :index, _Void, reader: :public
  prop :item, _Void, reader: :public
  prop :view, _Void, reader: :public
  prop :form, _Nilable(ActionView::Helpers::FormBuilder)
  prop :parent_resource, _Void
  prop :parent_record, _Void
  prop :parent_component, _Void
  prop :actions, _Nilable(_Array(Avo::BaseAction))
  prop :field_component_extra_args, Hash, default: -> { {} }

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
    Avo::TabGroupComponent.new(
      resource: @resource,
      group: item.hydrate(view: view),
      index: index,
      params: params,
      form: form,
      view: view
    )
  end

  def field_component
    final_item = item.dup.hydrate(resource: @resource, record: @resource.record, user: resource.user, view: view)
    final_item.component_for_view(@view).new(field: final_item, resource: @resource, index: index, form: form, turbo_frame_loading: :lazy, **@field_component_extra_args)
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
