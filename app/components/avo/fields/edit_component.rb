# frozen_string_literal: true

class Avo::Fields::EditComponent < ViewComponent::Base
  include Avo::ResourcesHelper

  attr_reader :compact
  attr_reader :displayed_in_modal
  attr_reader :field
  attr_reader :form
  attr_reader :index
  attr_reader :multiple
  attr_reader :resource
  attr_reader :view

  def initialize(field: nil, resource: nil, index: 0, form: nil, displayed_in_modal: false, compact: false, multiple: false, **kwargs)
    @compact = compact
    @displayed_in_modal = displayed_in_modal
    @field = field
    @form = form
    @index = index
    @multiple = multiple
    @resource = resource
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
      displayed_in_modal: displayed_in_modal,
      field: field,
      form: form,
      index: index,
      resource: resource,
      view: view
    }
  end
end
