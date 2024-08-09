# frozen_string_literal: true

class Avo::Fields::ShowComponent < Avo::BaseComponent
  include Avo::ResourcesHelper

  attr_reader :view

  prop :field, _Nilable(Avo::Fields::BaseField), reader: :public
  prop :resource, _Nilable(Avo::BaseResource), reader: :public
  prop :index, Integer, default: 0, reader: :public
  prop :form, _Nilable(ActionView::Helpers::FormBuilder), reader: :public
  prop :compact, _Boolean, default: false, reader: :public
  prop :short, _Boolean, default: false, reader: :public
  prop :stacked, _Nilable(_Boolean), reader: :public
  prop :kwargs, Hash, :**, default: {}.freeze, reader: :public

  def after_initialize
    @view = Avo::ViewInquirer.new("show")
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
      short: short,
      stacked: stacked,
      view: view
    }
  end

  def disabled?
    field.is_readonly? || field.is_disabled?
  end
end
