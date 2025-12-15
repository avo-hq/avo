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
    to: :@parent_component

  def args
    if @is_main_panel
      {
        title: title,
        description: @resource.description,
        index: 0,
        data: {panel_id: "main"},
        profile_photo: @resource.profile_photo,
      }
    else
      {
        title: @item.title,
        description: @item.description,
        index: @index
      }
    end
  end
end
