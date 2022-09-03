# frozen_string_literal: true

class Avo::Fields::IndexComponent < ViewComponent::Base
  include Avo::ResourcesHelper

  attr_reader :view

  def initialize(field: nil, resource: nil, index: 0, parent_model: nil)
    @field = field
    @resource = resource
    @index = index
    @parent_model = parent_model
    @view = :index
  end

  def resource_path
    return edit_path if Avo.configuration.skip_show_view

    if @parent_model.present?
      helpers.resource_path(model: @resource.model, resource: @resource, via_resource_class: @parent_model.class, via_resource_id: @parent_model.id)
    else
      helpers.resource_path(model: @resource.model, resource: @resource)
    end
  end

  #Full copy from Avo::Index::ResourceControlsComponent
  def edit_path
    # Add the `view` param to let Avo know where to redirect back when the user clicks the `Cancel` button.
    args = {via_view: "index"}

    if @parent_model.present?
      args = {
        via_resource_class: parent_resource.model_class,
        via_resource_id: @parent_model.id
      }
    end

    helpers.edit_resource_path(model: @resource.model, resource: @resource, **args)
  end

   #Full copy from Avo::Index::ResourceControlsComponent
  def parent_resource
    return nil if @parent_model.blank?

    ::Avo::App.get_resource_by_model_name @parent_model.class
  end
end
