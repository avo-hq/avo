# frozen_string_literal: true

class Avo::FieldWrapperComponent < ViewComponent::Base
  # attr_reader :classes
  attr_reader :dash_if_blank
  attr_reader :data
  attr_reader :displayed_in_modal
  # attr_reader :help
  attr_reader :field
  attr_reader :form
  attr_reader :full_width
  # attr_reader :label
  attr_reader :resource
  # attr_reader :record
  # attr_reader :style
  attr_reader :view

  def initialize(
    dash_if_blank: true,
    data: {},
    displayed_in_modal: false,
    help: nil, # do we really need it?
    field: nil,
    form: nil,
    full_width: false,
    label: nil, # do we really need it?
    resource: nil,
    style: "",
    view: :show,
    **args
  )
    @args = args
    @classes = args[:class].present? ? args[:class] : ""
    @dash_if_blank = dash_if_blank
    @data = data
    @displayed_in_modal = displayed_in_modal
    @help = help
    @field = field
    @form = form
    @full_width = full_width
    @label = label
    @resource = resource
    @style = style
    @view = view
  end

  def classes(extra_classes = "")
    "relative flex flex-col md:flex-row md:items-center pb-2 md:pb-0 leading-tight min-h-14 #{@classes || ""} #{extra_classes || ""} #{@field.get_html(:classes, view: view, element: :wrapper)}"
  end

  def style
    "#{@style} #{@field.get_html(:style, view: view, element: :wrapper)}"
  end

  def label
    @label || @field.name
  end

  def show?
    view == :show
  end

  def edit?
    view == :edit
  end

  def help
    @help || @field.help
  end

  def record
    resource.present? ? resource.model : nil
  end
end
