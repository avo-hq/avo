# frozen_string_literal: true

class Avo::Items::PanelComponent < Avo::ResourceComponent
  include Avo::ApplicationHelper

  prop :form, _Nilable(ActionView::Helpers::FormBuilder)
  prop :item, _Nilable(Avo::Resources::Items::Panel)
  prop :is_main_panel, _Nilable(_Boolean)
  prop :resource, Avo::BaseResource
  prop :view, Symbol do |value|
    value&.to_sym
  end
  prop :actions, _Nilable(_Array(Avo::BaseAction)), reader: :public
  prop :index, _Nilable(Integer), reader: :public
  prop :parent_component, _Nilable(ViewComponent::Base)
  prop :parent_record, _Nilable(ActiveRecord::Base)
  prop :parent_resource, _Nilable(Avo::BaseResource)
  prop :reflection, _Nilable(ActiveRecord::Reflection::AbstractReflection)

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
        data: {panel_id: "main"},
        cover_photo: @resource.cover_photo,
        profile_photo: @resource.profile_photo
      }
    else
      {name: @item.name, description: @item.description, index: @index}
    end
  end
end
