# frozen_string_literal: true

class Avo::Fields::EditComponent < ViewComponent::Base
  include Avo::ResourcesHelper

  attr_reader :field
  attr_reader :form
  attr_reader :index
  attr_reader :view
  attr_reader :resource
  attr_reader :compact

  def initialize(field: nil, resource: nil, index: 0, form: nil, displayed_in_modal: false, compact: false, **kwargs)
    @field = field
    @resource = resource
    @index = index
    @form = form
    @displayed_in_modal = displayed_in_modal
    @compact = compact
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
      field: field,
      index: index,
      form: form,
      resource: resource,
      displayed_in_modal: @displayed_in_modal,
      compact: compact,
      view: view
    }
  end
end
