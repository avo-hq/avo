# frozen_string_literal: true

class Avo::Index::ResourceControlsComponent < Avo::ResourceComponent
  def initialize(resource: nil, reflection: nil, parent_model: nil, view_type: :table)
    @resource = resource
    @reflection = reflection
    @parent_model = parent_model
    @view_type = view_type
  end

  def can_detach?
    @reflection.present? &&
      @resource.model.present? &&
      is_has_many_association &&
      authorize_association_for("detach")
  end

  def can_edit?
    return authorize_association_for(:edit) if @reflection.present?

    @resource.authorization.authorize_action(:edit, raise_exception: false)
  end

  def can_view?
    return authorize_association_for(:view) if @reflection.present?

    @resource.authorization.authorize_action(:show, raise_exception: false)
  end

  def show_path
    args = {}

    if @parent_model.present?
      args = {
        via_resource_class: parent_resource.model_class,
        via_resource_id: @parent_model.id
      }
    end

    helpers.resource_path(model: @resource.model, resource: @resource, **args)
  end

  def edit_path
    # Add the `view` param to let Avo know where to redirect back when the user clicks the `Cancel` button.
    args = {via_view: 'index'}

    if @parent_model.present?
      args = {
        via_resource_class: parent_resource.model_class,
        via_resource_id: @parent_model.id
      }
    end

    helpers.edit_resource_path(model: @resource.model, resource: @resource, **args)
  end

  def singular_resource_name
    if @reflection.present?
      reflection_resource.name
    else
      @resource.singular_name.present? ? @resource.singular_name : @resource.model_class.model_name.name.downcase
    end
  end

  def parent_resource
    return nil if @parent_model.blank?

    ::Avo::App.get_resource_by_model_name @parent_model.class
  end

  def is_has_many_association
    @reflection.is_a?(::ActiveRecord::Reflection::HasManyReflection) || @reflection.is_a?(::ActiveRecord::Reflection::ThroughReflection)
  end

  def referrer_path
    Avo::App.root_path(paths: ['resources', params[:resource_name], params[:id], params[:related_name]], query: request.query_parameters.to_h)
  end
end
