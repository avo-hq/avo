# frozen_string_literal: true

class Avo::Items::PanelComponent < Avo::ResourceComponent
  include Avo::ApplicationHelper

  prop :form
  prop :item
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
    {
      title: @item.title,
      description: @item.description,
      index: @index
    }
  end
end
