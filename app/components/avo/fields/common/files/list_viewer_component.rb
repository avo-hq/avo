# frozen_string_literal: true

class Avo::Fields::Common::Files::ListViewerComponent < ViewComponent::Base
  include Turbo::FramesHelper

  def initialize(field:, resource:)
    @field = field
    @resource = resource
  end

  def classes
    base_classes = "py-4 rounded-xl"

    view_type_classes = if @field.view_type == :list
      "flex flex-col space-y-2"
    else
      "relative grid xs:grid-cols-2 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 2xl:grid-cols-6 gap-6"
    end

    "#{base_classes} #{view_type_classes}"
  end

  def available_view_types
    [:list, :grid]
  end
end
