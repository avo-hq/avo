# frozen_string_literal: true

class Avo::Index::FieldWrapperComponent < Avo::BaseComponent
  attr_reader :view

  prop :field, Avo::Fields::BaseField
  prop :resource, _Any
  prop :dash_if_blank, _Boolean, default: true
  prop :center_content, _Boolean, default: false
  prop :flush, _Boolean, default: false
  prop :class, String, default: ""

  def after_initialize
    @view = Avo::ViewInquirer.new("index")
  end

  def classes
    result = @class

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
