# frozen_string_literal: true

class Avo::Index::FieldWrapperComponent < ViewComponent::Base
  attr_reader :view

  def initialize(field: nil, resource: nil, dash_if_blank: true, center_content: false, flush: false, **args)
    @field = field
    @resource = resource
    @dash_if_blank = dash_if_blank
    @center_content = center_content
    @classes = args[:class].present? ? args[:class] : ""
    @args = args
    @flush = flush
    @view = Avo::ViewInquirer.new("index")
  end

  def classes
    result = @classes

    unless @flush
      result += " py-3"
    end

    result += " #{@field.get_html(:classes, view: view, element: :wrapper)}"

    result
  end

  def style
    @field.get_html(:style, view: view, element: :wrapper)
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
