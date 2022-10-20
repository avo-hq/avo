# frozen_string_literal: true

class Avo::Fields::EditComponent < ViewComponent::Base
  include Avo::ResourcesHelper

  attr_reader :compact
  attr_reader :field
  attr_reader :form
  attr_reader :index
  attr_reader :multiple
  attr_reader :resource
  attr_reader :stacked
  attr_reader :view

  def initialize(field: nil, resource: nil, index: 0, form: nil, compact: false, stacked: false, multiple: false, **kwargs)
    @compact = compact
    @field = field
    @form = form
    @index = index
    @multiple = multiple
    @resource = resource
    @stacked = stacked
    @view = :edit
  end

  def classes(extra_classes = "")
    helpers.input_classes("#{@field.get_html(:classes, view: view, element: :input)} #{extra_classes}", has_error: @field.model_errors.include?(@field.id))
  end

  def render?
    !field.computed
  end

  def field_wrapper_args
    {
      compact: compact,
      field: field,
      form: form,
      index: index,
      resource: resource,
      stacked: stacked,
      view: view
    }
  end
end
