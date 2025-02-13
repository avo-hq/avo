# frozen_string_literal: true

class Avo::Fields::PreviewField::IndexComponent < Avo::Fields::IndexComponent
  def render_preview
    link_to resource_view_path, title: t("avo.view_item", item: @resource.name).humanize do
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
end
