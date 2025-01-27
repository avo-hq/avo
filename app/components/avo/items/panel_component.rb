# frozen_string_literal: true

class Avo::Items::PanelComponent < Avo::ResourceComponent
  include Avo::ApplicationHelper

  prop :form
  prop :item
  prop :is_main_panel
  prop :resource
  prop :view
  prop :actions, reader: :public
  prop :index, reader: :public
  prop :parent_component
  prop :parent_record
  prop :parent_resource
  prop :reflection

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
        profile_photo: @resource.profile_photo,
        external_link: @resource.get_external_link
      }
    else
      {name: @item.name, description: @item.description, index: @index}
    end
  end
end
