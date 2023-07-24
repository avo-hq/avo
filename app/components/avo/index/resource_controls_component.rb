# frozen_string_literal: true

class Avo::Index::ResourceControlsComponent < Avo::ResourceComponent
  def initialize(resource: nil, reflection: nil, parent_model: nil, parent_resource: nil, view_type: :table)
    @resource = resource
    @reflection = reflection
    @parent_model = parent_model
    @parent_resource = parent_resource
    @view_type = view_type
  end

  def can_detach?
    is_has_many_association? ? super : false
  end

  def can_edit?
    return authorize_association_for(:edit) if @reflection.present?

    @resource.authorization.authorize_action(:edit, raise_exception: false)
  end

  def can_view?
    return false if Avo.configuration.resource_default_view == :edit

    return authorize_association_for(:show) if @reflection.present?

    # Even if there's a @reflection object present, for show we're going to fallback to the original policy.
    @resource.authorization.authorize_action(:show, raise_exception: false)
  end

  def can_reorder?
    return authorize_association_for(:reorder) if @reflection.present?

    @resource.authorization.authorize_action(:reorder, raise_exception: false)
  end

  def show_path
    args = {}

    if @parent_model.present?
      args = {
        via_resource_class: parent_resource.class.to_s,
        via_resource_id: @parent_model.to_param
      }
    end

    helpers.resource_path(model: @resource.model, resource: parent_or_child_resource , **args)
  end

  def edit_path
    # Add the `view` param to let Avo know where to redirect back when the user clicks the `Cancel` button.
    args = {via_view: "index"}

    if @parent_model.present?
      args = {
        via_resource_class: parent_resource.class.to_s,
        via_resource_id: @parent_model.to_param
      }
    end

    helpers.edit_resource_path(model: @resource.model, resource: parent_or_child_resource, **args)
  end

  def singular_resource_name
    if @reflection.present?
      field&.name&.singularize || reflection_resource.name
    else
      @resource.singular_name.present? ? @resource.singular_name : @resource.model_class.model_name.name.downcase
    end
  end

  def parent_resource
    return @parent_resource if @parent_resource.present?
    return nil if @parent_model.blank?

    ::Avo::App.get_resource_by_model_name @parent_model.class
  end

  def is_has_many_association?
    @reflection.is_a?(::ActiveRecord::Reflection::HasManyReflection) || @reflection.is_a?(::ActiveRecord::Reflection::ThroughReflection)
  end

  def referrer_path
    Avo::App.root_path(paths: ["resources", params[:resource_name], params[:id], params[:related_name]], query: request.query_parameters.to_h)
  end
end
