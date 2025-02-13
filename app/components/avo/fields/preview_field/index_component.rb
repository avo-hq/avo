# frozen_string_literal: true

class Avo::Fields::PreviewField::IndexComponent < Avo::Fields::IndexComponent
  include Avo::Concerns::ChecksShowAuthorization

  def render_preview
    # Do not render the link if the user is not authorized to view the resource,
    # as the link exposes the result of `record.to_param`.
    return preview_icon if !can_view?

    link_to resource_view_path, title: t('avo.view_item', item: @resource.name).humanize do
      preview_icon
    end
  end

  def preview_icon
    helpers.svg(
      "heroicons/outline/magnifying-glass-circle",
      class: "block h-6 text-gray-600",
      data: {
        controller: "preview",
        preview_url_value: helpers.preview_resource_path(resource: @resource, turbo_frame: :preview_modal),
      }
    )
  end
end
