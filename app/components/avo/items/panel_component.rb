# frozen_string_literal: true

class Avo::Items::PanelComponent < Avo::ResourceComponent
  include Avo::ApplicationHelper

  def initialize(form:, item:, is_main_panel:, resource:, view:, actions: nil, index: nil, parent_component: nil, parent_record: nil, parent_resource: nil, reflection: nil)
    @actions = actions
    @form = form
    @index = index
    @is_main_panel = is_main_panel
    @item = item
    @parent_component = parent_component
    @parent_record = parent_record
    @parent_resource = parent_resource
    @reflection = reflection
    @resource = resource
    @view = view
  end

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
