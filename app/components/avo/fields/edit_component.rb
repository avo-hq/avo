# frozen_string_literal: true

class Avo::Fields::EditComponent < Avo::BaseComponent
  include Avo::ResourcesHelper

  attr_reader :field
  attr_reader :form
  attr_reader :index
  attr_reader :kwargs
  attr_reader :multiple
  attr_reader :resource
  attr_reader :stacked
  attr_reader :view
  attr_reader :full_width

  def initialize(field: nil, resource: nil, index: 0, form: nil, stacked: nil, full_width: nil, multiple: false, autofocus: false, **kwargs)
    @field = field
    @form = form
    @index = index
    @kwargs = kwargs
    @multiple = multiple
    @resource = resource
    @stacked = stacked
    @view = Avo::ViewInquirer.new("edit")
    @autofocus = autofocus
    @full_width = full_width
  end

  def classes(extra_classes = "")
    helpers.input_classes("#{@field.get_html(:classes, view: view, element: :input)} #{extra_classes}", has_error: @field.record_errors.include?(@field.id))
  end

  def render?
    !field.computed
  end

  def field_wrapper_args
    {
      field: field,
      form: form,
      index: index,
      resource: resource,
      stacked: stacked,
      full_width: full_width,
      view: view
    }
  end

  def disabled?
    field.is_readonly? || field.is_disabled?
  end
end
