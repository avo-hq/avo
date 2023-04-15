# frozen_string_literal: true

class Avo::Fields::Common::Files::ListViewerComponent < ViewComponent::Base
  include Turbo::FramesHelper

  def initialize(field:, resource:)
    @field = field
    @resource = resource
  end

  def classes
    base_class = "py-3 gap-3 rounded-xl"

    view_type_class = if @field.view_type == :list
      "flex flex-col"
    else
      "relative grid xs:grid-cols-2 sm:grid-cols-2 xl:grid-cols-3 2xl:grid-cols-4"
    end

    "#{base_class} #{view_type_class}"
  end

  def available_view_types
    [:list, :grid]
  end
end
