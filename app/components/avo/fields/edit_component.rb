# frozen_string_literal: true

class Avo::Fields::EditComponent < Avo::BaseComponent
  include Avo::ResourcesHelper

  prop :field, _Nilable(Avo::Fields::BaseField), reader: :public
  prop :resource, _Nilable(Avo::BaseResource), reader: :public
  prop :index, Integer, default: 0, reader: :public
  prop :form, _Nilable(ActionView::Helpers::FormBuilder), reader: :public
  prop :compact, _Boolean, default: false, reader: :public
  prop :stacked, _Boolean, default: false, reader: :public
  prop :multiple, _Boolean, default: false, reader: :public
  prop :autofocus, _Boolean, default: false, reader: :public
  prop :kwargs, Hash, :**, reader: :public

  attr_reader :view

  def after_initialize
  	@view = Avo::ViewInquirer.new("edit")
  end

  def classes(extra_classes = "")
    helpers.input_classes("#{@field.get_html(:classes, view: view, element: :input)} #{extra_classes}", has_error: @field.record_errors.include?(@field.id))
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

  def disabled?
    field.is_readonly? || field.is_disabled?
  end
end
