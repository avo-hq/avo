# frozen_string_literal: true

class Avo::Fields::ShowComponent < ViewComponent::Base
  include Avo::ResourcesHelper

  attr_reader :compact
  attr_reader :field
  attr_reader :index
  attr_reader :resource
  attr_reader :stacked
  attr_reader :view

  def initialize(field: nil, resource: nil, index: 0, form: nil, compact: false, stacked: false)
    @compact = compact
    @field = field
    @index = index
    @resource = resource
    @stacked = stacked
    @view = :show
  end

  def wrapper_data
    {
      **stimulus_attributes
    }
  end

  def stimulus_attributes
    attributes = {}

    if @resource.present?
      @resource.get_stimulus_controllers.split(" ").each do |controller|
        attributes["#{controller}-target"] = "#{@field.id.to_s.underscore}_#{@field.type.to_s.underscore}_wrapper".camelize(:lower)
      end
    end

    wrapper_data_attributes = @field.get_html :data, view: view, element: :wrapper
    if wrapper_data_attributes.present?
      attributes.merge! wrapper_data_attributes
    end

    attributes
  end

  def field_wrapper_args
    {
      compact: compact,
      field: field,
      index: index,
      resource: resource,
      stacked: stacked,
      view: view
    }
  end
end
