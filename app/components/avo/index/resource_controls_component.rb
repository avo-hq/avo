# frozen_string_literal: true

class Avo::Index::ResourceControlsComponent < Avo::ResourceComponent
  include Avo::ApplicationHelper
  include Avo::Concerns::ChecksShowAuthorization

  prop :resource
  prop :reflection
  prop :parent_record
  prop :parent_resource
  prop :view_type, default: :table
  prop :actions

  def can_detach?
    is_has_many_association? ? super : false
  end

  def can_edit?
    # Disable edit for ArrayResources
    return false if @resource.resource_type_array?

    return authorize_association_for(:edit) if @reflection.present?

    @resource.authorization.authorize_action(:edit, raise_exception: false)
  end

  def show_path
    helpers.resource_show_path(resource: @resource, parent_or_child_resource: parent_or_child_resource, parent_resource: parent_resource, parent_record: @parent_record)
  end

  def edit_path
    # Add the `view` param to let Avo know where to redirect back when the user clicks the `Cancel` button.
    args = {via_view: "index"}

    if @parent_record.present?
      args = {
        via_resource_class: parent_resource.class.to_s,
        via_record_id: @parent_record.to_param
      }
    end

    helpers.edit_resource_path(record: @resource.record, resource: parent_or_child_resource, **args)
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
    return nil if @parent_record.blank?

    Avo.resource_manager.get_resource_by_model_class @parent_record.class
  end

  def is_has_many_association?
    @reflection.class.in? [
      ActiveRecord::Reflection::HasManyReflection,
      ActiveRecord::Reflection::HasAndBelongsToManyReflection,
      ActiveRecord::Reflection::ThroughReflection
    ]
  end

  def referrer_path
    Avo.root_path(paths: ["resources", params[:resource_name], params[:id], params[:related_name]], query: request.query_parameters.to_h)
  end

  private

  def render_edit_button(control)
    return unless can_edit?

    link_to helpers.svg("tabler/outline/edit", class: svg_classes),
      edit_path,
      class: "flex items-center",
      title: control.title,
      aria: {label: control.title},
      data: {
        target: "control:edit",
        control: :edit,
        "resource-id": @resource.record_param,
        tippy: "tooltip",
      }
  end

  def render_show_button(control)
    return unless can_view?

    link_to helpers.svg("tabler/outline/eye", class: svg_classes),
      show_path,
      class: "flex items-center",
      title: control.title,
      aria: {label: control.title},
      data: {
        target: "control:view",
        control: :show,
        tippy: "tooltip",
      }
  end

  def render_delete_button(control)
    # If the resource is a related resource, we use the can_delete? policy method because it uses
    # authorize_association_for(:destroy).
    # Otherwise we use the can_see_the_destroy_button? policy method because it do no check for association
    # only for authorize_action .
    policy_method = is_a_related_resource? ? :can_delete? : :can_see_the_destroy_button?
    return unless send policy_method

    link_to svg("tabler/outline/trash", class: svg_classes), helpers.resource_path(record: @resource.record, resource: @resource, **hidden_params),
      class: "flex flex-col sm:flex-row sm:inline-flex",
      title: control.title,
      aria: {label: control.title},
      data: {
        turbo_frame: params[:turbo_frame],
        turbo_confirm: control.confirmation_message,
        turbo_method: :delete,
        target: "control:destroy",
        control: :destroy,
        tippy: control.title ? :tooltip : nil,
        "resource-id": @resource.record_param,
      }
  end

  def render_detach_button(control)
    return unless can_detach?

    link_to svg("tabler/outline/unlink", class: svg_classes), helpers.resource_detach_path(params[:resource_name], params[:id], params[:related_name], @resource.record_param, **hidden_params),
      title: control.title,
      aria: {label: control.title},
      data: {
        turbo_method: :delete,
        turbo_frame: params[:turbo_frame],
        turbo_confirm: control.confirmation_message,
        target: "control:detach",
        control: :detach,
        "resource-id": @resource.record_param,
        tippy: :tooltip,
      }
  end

  def render_order_controls(control)
    if try(:can_reorder?)
      render Avo::Pro::Ordering::ButtonsComponent.new resource: @resource, reflection: @reflection, view_type: @view_type
    end
  end

  def svg_classes
    "h-6"
  end

  def hidden_params
    hidden = {}

    hidden[:view_type] = params[:view_type] if params[:view_type]
    hidden[:view] = parent_resource&.view&.to_s

    if params[:turbo_frame]
      hidden[:turbo_frame] = params[:turbo_frame]
      hidden[:referrer] = referrer_path
    end

    hidden.compact
  end

  def view_type
    params[:view_type]
  end
end
