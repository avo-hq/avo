# frozen_string_literal: true

class Avo::CommonFieldWrapperComponent < ViewComponent::Base
  attr_reader :view

  def initialize(field: nil, dash_if_blank: true, full_width: false, displayed_in_modal: false, form: nil, resource: nil, label: nil, view: nil, **args)
    @field = field
    @dash_if_blank = dash_if_blank
    @classes = args[:class].present? ? args[:class] : ""
    @args = args
    @displayed_in_modal = displayed_in_modal
    @form = form
    @resource = resource
    @model = resource.present? ? resource.model : nil
    @full_width = full_width
    @label = label
    @view = view
  end

  def classes(extra_classes = "")
    "#{@classes || ""} #{extra_classes || ""} #{@field.get_html(:classes, view: view, element: :wrapper)}"
  end

  def style
    @field.get_html(:style, view: view, element: :wrapper)
  end

  def label
    @label || @field.name
  end

  def stimulus_attributes
    attributes = {}

    @resource.get_stimulus_controllers.split(" ").each do |controller|
      attributes["#{controller}-target"] = "#{@field.id.to_s.underscore}_#{@field.type.to_s.underscore}_wrapper".camelize(:lower)
    end

    wrapper_data_attributes = @field.get_html :data, view: view, element: :wrapper
    if wrapper_data_attributes.present?
      attributes.merge! wrapper_data_attributes
    end

    attributes
  end
end
