# frozen_string_literal: true

class Avo::FieldWrapperComponent < ViewComponent::Base
  attr_reader :dash_if_blank
  attr_reader :compact
  attr_reader :field
  attr_reader :form
  attr_reader :full_width
  attr_reader :resource
  attr_reader :view

  def initialize(
    dash_if_blank: true,
    data: {},
    compact: false,
    help: nil, # do we really need it?
    field: nil,
    form: nil,
    full_width: false,
    label: nil, # do we really need it?
    resource: nil,
    stacked: false,
    style: "",
    view: :show,
    **args
  )
    @args = args
    @classes = args[:class].present? ? args[:class] : ""
    @dash_if_blank = dash_if_blank
    @data = data
    @compact = compact
    @help = help
    @field = field
    @form = form
    @full_width = full_width
    @label = label
    @resource = resource
    @stacked = stacked
    @style = style
    @view = view
  end

  def classes(extra_classes = "")
    "relative flex flex-col flex-grow pb-2 md:pb-0 leading-tight min-h-14 #{stacked? ? "" : "md:flex-row md:items-center"} #{@classes || ""} #{extra_classes || ""} #{@field.get_html(:classes, view: view, element: :wrapper)}"
  end

  def style
    "#{@style} #{@field.get_html(:style, view: view, element: :wrapper)}"
  end

  def label
    @label || @field.name
  end

  def on_show?
    view == :show
  end

  def on_edit?
    view == :edit
  end

  def help
    @help || @field.help
  end

  def record
    resource.present? ? resource.model : nil
  end

  def data
    attributes = {
      field_id: @field.id,
      field_type: @field.type
    }

    # Add the built-in stimulus integration data tags.
    if @resource.present?
      @resource.get_stimulus_controllers.split(" ").each do |controller|
        attributes["#{controller}-target"] = "#{@field.id.to_s.underscore}_#{@field.type.to_s.underscore}_wrapper".camelize(:lower)
      end
    end

    # Fetch the data attributes off the html option
    wrapper_data_attributes = @field.get_html :data, view: view, element: :wrapper
    if wrapper_data_attributes.present?
      attributes.merge! wrapper_data_attributes
    end

    attributes
  end

  def stacked?
    @stacked
  end

  def compact?
    @compact
  end

  def full_width?
    @full_width
  end
end
