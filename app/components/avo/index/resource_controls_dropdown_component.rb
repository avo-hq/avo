# frozen_string_literal: true

class Avo::Index::ResourceControlsDropdownComponent < Avo::Index::ResourceControlsComponent
  private

  def detach_path
    helpers.resource_detach_path(params[:resource_name], params[:id], params[:related_name], @resource.record_param, **hidden_params)
  end

  def delete_path
    helpers.resource_path(record: @resource.record, resource: @resource, **hidden_params)
  end

  def render_edit_button(control)
    return unless can_edit?

    link_options = {
      class: "flex items-center gap-2",
      aria: {label: control.title},
      data: {
        target: "control:edit",
        control: :edit,
        "resource-id": @resource.record_param,
      }
    }

    link_to edit_path, **link_options do
      concat svg("tabler/outline/edit", class: svg_classes)
      concat control_title_without_resource(control.title)
    end
  end

  def render_show_button(control)
    return unless can_view?

    link_options = {
      class: "flex items-center gap-2",
      aria: {label: control.title},
      data: {
        target: "control:view",
        control: :show,
      }
    }

    link_to show_path, **link_options do
      concat svg("tabler/outline/eye", class: svg_classes)
      concat control_title_without_resource(control.title)
    end
  end

  def render_delete_button(control)
    # If the resource is a related resource, we use the can_delete? policy method because it uses
    # authorize_association_for(:destroy).
    # Otherwise we use the can_see_the_destroy_button? policy method because it do no check for association
    # only for authorize_action .
    policy_method = is_a_related_resource? ? :can_delete? : :can_see_the_destroy_button?
    return unless send policy_method

    link_options = {
      form_class: "flex flex-col sm:flex-row sm:inline-flex",
      aria: {label: control.title},
      data: {
        turbo_frame: params[:turbo_frame],
        turbo_confirm: control.confirmation_message,
        turbo_method: :delete,
        target: "control:destroy",
        control: :destroy,
        "resource-id": @resource.record_param,
      }
    }

    link_to delete_path, **link_options do
      concat svg("tabler/outline/trash", class: svg_classes)
      concat control_title_without_resource(control.title)
    end
  end

  def render_detach_button(control)
    return unless can_detach?

    link_options = {
      title: control.title,
      aria: {label: control.title},
      data: {
        turbo_method: :delete,
        turbo_frame: params[:turbo_frame],
        turbo_confirm: control.confirmation_message,
        target: "control:detach",
        control: :detach,
        "resource-id": @resource.record_param,
      }
    }

    svg = svg("tabler/outline/unlink", class: svg_classes)
    link_to detach_path, **link_options do
      concat svg
      concat control.title
    end
  end

  def control_title_without_resource(title)
    # Remove resource name in any case (Product, product, PRODUCT)
    resource_name = singular_resource_name.humanize
    title.gsub(/\b#{Regexp.escape(resource_name)}\b/i, "").strip
  end
end
