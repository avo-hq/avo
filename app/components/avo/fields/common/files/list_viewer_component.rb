# frozen_string_literal: true

class Avo::Fields::Common::Files::ListViewerComponent < Avo::BaseComponent
  include Turbo::FramesHelper

  prop :field
  prop :resource

  def classes
    base_classes = "py-4 rounded-2xl max-w-full"

    view_type_classes = if view_type == :list
      "flex flex-col space-y-2"
    else
      "relative grid xs:grid-cols-2 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 2xl:grid-cols-6 gap-6"
    end

    "#{base_classes} #{view_type_classes}"
  end

  def wrapper_classes
    (@field.stacked && !@field.hide_view_type_switcher) ? "-mt-9" : ""
  end

  def available_view_types
    [:list, :grid]
  end

  def view_type_component(file)
    component = "Avo::Fields::Common::Files::ViewType::#{view_type.to_s.capitalize}ItemComponent".constantize
    component.new(field: @field, resource: @resource, file: file, extra_classes: "aspect-video")
  end

  def view_type
    @view_type ||= (@resource.params.dig(:view_type) || @field.view_type).to_sym
  end
end
