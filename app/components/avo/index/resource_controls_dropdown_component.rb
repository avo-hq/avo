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

    link_to edit_path, **control_link_options(control, target: "edit", control_key: :edit) do
      concat svg("tabler/outline/edit")
      concat control_title_without_resource(control.title)
    end
  end

  def render_show_button(control)
    return unless can_view?

    link_to show_path, **control_link_options(control, target: "view", control_key: :show, include_resource_id: false) do
      concat svg("tabler/outline/eye")
      concat control_title_without_resource(control.title)
    end
  end

  def render_delete_button(control)
    return unless destroy_permitted?

    link_to delete_path, **control_link_options(control, target: "destroy", control_key: :destroy,
      turbo_frame: params[:turbo_frame],
      turbo_confirm: control.confirmation_message,
      turbo_method: :delete) do
      concat svg("tabler/outline/trash")
      concat control_title_without_resource(control.title)
    end
  end

  def render_detach_button(control)
    return unless can_detach?

    link_to detach_path, **control_link_options(control, target: "detach", control_key: :detach,
      turbo_frame: params[:turbo_frame],
      turbo_confirm: control.confirmation_message,
      turbo_method: :delete) do
      concat svg("tabler/outline/unlink")
      concat control_title_without_resource(control.title)
    end
  end

  def control_link_options(control, target:, control_key:, include_resource_id: true, **extra_data)
    data = {
      target: "control:#{target}",
      control: control_key,
    }
    data["resource-id"] = @resource.record_param if include_resource_id
    data.merge!(extra_data)

    {
      aria: {label: control.title},
      title: control.title,
      data: data,
    }
  end

  def destroy_permitted?
    # Related resources use can_delete? (authorize_association_for :destroy); index uses can_see_the_destroy_button?
    policy_method = is_a_related_resource? ? :can_delete? : :can_see_the_destroy_button?
    send(policy_method)
  end

  def control_title_without_resource(title)
    resource_name = singular_resource_name.humanize
    title.gsub(/\b#{Regexp.escape(resource_name)}\b/i, "").strip
  end
end
