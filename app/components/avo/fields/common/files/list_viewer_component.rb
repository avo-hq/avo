# frozen_string_literal: true

class Avo::Fields::Common::Files::ListViewerComponent < Avo::BaseComponent
  include Turbo::FramesHelper

  prop :field
  prop :resource

  def after_initialize
    @available_view_types = [:list, :grid]

    params_view_type = @resource.params.dig(:view_type)&.to_sym

    @view_type = if params_view_type.in?(@available_view_types)
      params_view_type
    else
      @field.view_type
    end

    @component_class = "Avo::Fields::Common::Files::ViewType::#{@view_type.to_s.capitalize}ItemComponent".constantize
  end

  def view_type_component(file)
    @component_class.new(field: @field, resource: @resource, file: file, extra_classes: "aspect-video")
  end
end
