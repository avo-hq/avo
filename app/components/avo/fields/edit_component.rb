# frozen_string_literal: true

class Avo::Fields::EditComponent < ViewComponent::Base
  include Avo::ResourcesHelper

  attr_reader :field
  attr_reader :view

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
end
