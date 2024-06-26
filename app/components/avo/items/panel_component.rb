# frozen_string_literal: true

class Avo::Items::PanelComponent < Avo::ResourceComponent
  include Avo::ApplicationHelper

  prop :form, _Nilable(ActionView::Helpers::FormBuilder)
  prop :item, _Any
  prop :is_main_panel, _Boolean
  prop :resource, Avo::BaseResource
  prop :view, Symbol, &:to_sym
  prop :actions, _Nilable(_Array(Avo::BaseAction))
  prop :index, _Nilable(Integer)
  prop :parent_component, _Void
  prop :parent_record, _Nilable(ActiveRecord::Base)
  prop :parent_resource, _Nilable(Avo::BaseResource)
  prop :reflection, _Nilable(ActiveRecord::Reflection::AssociationReflection)

  delegate :controls,
    :title,
    :back_path,
    :edit_path,
    :can_see_the_destroy_button?,
    :can_see_the_save_button?,
    :view_for,
    :display_breadcrumbs,
    to: :@parent_component

  def args
    if @is_main_panel
      {
        name: title,
        description: @resource.description,
        display_breadcrumbs: display_breadcrumbs,
        index: 0,
        data: {panel_id: "main"}
      }
    else
      {name: @item.name, description: @item.description, index: @index}
    end
  end
end
