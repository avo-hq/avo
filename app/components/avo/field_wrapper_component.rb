# frozen_string_literal: true

class Avo::FieldWrapperComponent < Avo::BaseComponent
  include Avo::Concerns::HasResourceStimulusControllers

  prop :dash_if_blank, _Boolean, default: true, reader: :public
  prop :data, Hash, default: -> { {} }
  prop :compact, _Boolean, default: false, reader: :public, predicate: :public
  prop :help, _Nilable(String) # do we really need it?
  prop :field, Avo::Fields::BaseField, reader: :public
  prop :form, _Nilable(ActionView::Helpers::FormBuilder), reader: :public
  prop :full_width, _Boolean, default: false, reader: :public, predicate: :public
  prop :label, _Nilable(String) # do we really need it?
  prop :resource, _Nilable(Avo::BaseResource), reader: :public
  prop :short, _Boolean, default: false, predicate: :public
  prop :stacked, _Boolean, default: false do |value|
    !!value
  end
  prop :style, String, default: ""
  prop :view, String, default: "show", reader: :public
  prop :label_for, _Nilable(String)
  prop :args, Hash, :**

  def after_initialize
    @action = field.action
    @classes = @args[:class].present? ? @args[:class] : ""
  end

  def classes(extra_classes = "")
    "field-wrapper relative flex flex-col grow pb-2 md:pb-0 leading-tight min-h-14 h-full #{stacked? ? "field-wrapper-layout-stacked" : "field-wrapper-layout-inline md:flex-row md:items-center"} #{compact? ? "field-wrapper-size-compact" : "field-wrapper-size-regular"} #{full_width? ? "field-width-full" : "field-width-regular"} #{@classes || ""} #{extra_classes || ""} #{@field.get_html(:classes, view: view, element: :wrapper)}"
  end

  def style
    "#{@style} #{@field.get_html(:style, view: view, element: :wrapper)}"
  end

  def label
    @label || @field.name
  end

  def label_for
    @label_for || @field.form_field_label
  end

  delegate :show?, :edit?, to: :view, prefix: :on

  def help
    Avo::ExecutionContext.new(target: @help || @field.help, record: record, resource: resource, view: view).handle
  end

  def record
    resource.present? ? resource.record : nil
  end

  def data
    attributes = {
      field_id: @field.id,
      field_type: @field.type,
      **@data
    }

    # Fetch the data attributes off the html option
    wrapper_data_attributes = @field.get_html :data, view: view, element: :wrapper
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
    @stacked || field.stacked || Avo.configuration.field_wrapper_layout == :stacked
  end
end
