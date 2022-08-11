# frozen_string_literal: true

class Avo::Fields::EditComponent < ViewComponent::Base
  include Avo::ResourcesHelper

  attr_reader :field
  attr_reader :form
  attr_reader :view
  attr_reader :resource

  def initialize(field: nil, resource: nil, index: 0, form: nil, displayed_in_modal: false)
    @field = field
    @resource = resource
    @index = index
    @form = form
    @displayed_in_modal = displayed_in_modal
    @view = :edit
  end

  def classes(extra_classes = "")
    helpers.input_classes("#{@field.get_html(:classes, view: view, element: :input)} #{extra_classes}", has_error: @field.model_errors.include?(@field.id))
  end

  def render?
    !field.computed
  end

  def wrapper_data
    attributes = {}

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
end
