# frozen_string_literal: true

class Avo::FieldWrapperComponent < Avo::BaseComponent
  include Avo::Concerns::HasResourceStimulusControllers

  prop :dash_if_blank, default: true
  prop :data, default: {}.freeze
  prop :compact, default: false
  prop :help
  prop :field
  prop :form
  prop :full_width, default: false
  prop :label
  prop :resource
  prop :short, default: false
  prop :stacked
  prop :style, default: ""
  prop :view, default: Avo::ViewInquirer.new(:show).freeze
  prop :label_for do |value|
    value&.to_sym
  end
  prop :args, kind: :**, default: {}.freeze
  prop :classes do |value|
    @args&.dig(:class) || ""
  end

  def after_initialize
    @action = @field.action
  end

  def classes(extra_classes = "")
    class_names("field-wrapper relative flex flex-col grow pb-2 md:pb-0 leading-tight h-full",
      @classes,
      extra_classes,
      @field.get_html(:classes, view: @view, element: :wrapper),
      {
        "min-h-14": !short?,
        "min-h-10": short?,
        "field-wrapper-size-compact": compact?,
        "field-wrapper-size-regular": !compact?,
        "field-width-full": full_width?,
        "field-width-regular": !full_width?,
        "field-wrapper-layout-stacked": stacked?,
        "field-wrapper-layout-inline md:flex-row md:items-center": !stacked?
      })
  end

  def style
    "#{@style} #{@field.get_html(:style, view: @view, element: :wrapper)}"
  end

  def label
    @label || @field.name
  end

  def label_for
    @label_for || @field.form_field_label
  end

  delegate :show?, :edit?, to: :@view, prefix: :on

  def help
    Avo::ExecutionContext.new(target: @help || @field.help, record: record, resource: @resource, view: @view).handle
  end

  def record
    @resource.present? ? @resource.record : nil
  end

  def data
    attributes = {
      field_id: @field.id,
      field_type: @field.type,
      **@data
    }

    # Fetch the data attributes off the html option
    wrapper_data_attributes = @field.get_html :data, view: @view, element: :wrapper
    if wrapper_data_attributes.present?
      attributes.merge! wrapper_data_attributes
    end

    # Add the built-in stimulus integration data tags.
    if @resource.present?
      add_stimulus_attributes_for(@resource, attributes)
    end

    if @action.present?
      add_stimulus_attributes_for(@action, attributes)
    end

    attributes
  end

  def stacked?
    # Override on the declaration level
    return @stacked unless @stacked.nil?

    # Fetch it from the field
    return @field.stacked unless @field.stacked.nil?

    # Fallback to defaults
    Avo.configuration.field_wrapper_layout == :stacked
  end

  def compact?
    @compact
  end

  def short?
    @short
  end

  def full_width?
    @full_width
  end

  def render_dash?
    if @field.type == "boolean"
      @field.value.nil?
    else
      @field.value.blank? && @dash_if_blank
    end
  end
end
