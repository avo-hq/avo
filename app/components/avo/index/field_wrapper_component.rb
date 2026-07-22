# frozen_string_literal: true

class Avo::Index::FieldWrapperComponent < Avo::BaseComponent
  # Vertical padding for each density step. `nil` density falls back to
  # `Avo.configuration.density`.
  DENSITY_PADDING = {
    tight: "py-2",
    normal: "py-4",
    relaxed: "py-6"
  }.freeze

  prop :field
  prop :resource
  prop :dash_if_blank, default: true
  prop :center_content, default: false
  prop :flush, default: false
  prop :density, default: nil
  # The wrapper element. Defaults to a table cell; non-table hosts (e.g. the
  # dashboards list card) render the same field components inside a :div.
  prop :html_tag, default: :td
  prop :args, kind: :**, default: {}.freeze

  def after_initialize
    @view = Avo::ViewInquirer.new("index")
    @classes = @args.dig(:class) || ""
  end

  def stimulus_attributes
    attributes = {}

    @resource.get_stimulus_controllers.split(" ").each do |controller|
      attributes["#{controller}-target"] = "#{@field.id.to_s.underscore}_#{@field.type.to_s.underscore}_wrapper".camelize(:lower)
    end

    wrapper_data_attributes = @field.get_html :data, view: @view, element: :wrapper
    if wrapper_data_attributes.present?
      attributes.merge! wrapper_data_attributes
    end

    attributes
  end

  def render_dash?
    @field.value.blank? && @dash_if_blank
  end

  def density_padding_class
    DENSITY_PADDING[(@density || Avo.configuration.density)&.to_sym] || DENSITY_PADDING[:normal]
  end
end
