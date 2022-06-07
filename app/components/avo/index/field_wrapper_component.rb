# frozen_string_literal: true

class Avo::Index::FieldWrapperComponent < ViewComponent::Base
  def initialize(field: nil, resource: nil, dash_if_blank: true, center_content: false, flush: false, **args)
    @field = field
    @resource = resource
    @dash_if_blank = dash_if_blank
    @center_content = center_content
    @classes = args[:class].present? ? args[:class] : ""
    @args = args
    @flush = flush
  end

  def classes
    result = @classes

    unless @flush
      result += " py-3"
    end

    result += " #{text_align_classes}"

    result
  end

  def stimulus_attributes
    attributes = {}

    @resource.get_stimulus_controllers.split(" ").each do |controller|
      attributes["#{controller}-target"] = "#{@field.id.to_s.underscore}_#{@field.type.to_s.underscore}_wrapper".camelize(:lower)
    end

    attributes
  end

  private

  def text_align_classes
    case @field.index_text_align.to_sym
    when :right
      "text-right"
    when :center
      "text-center"
    end
  end
end
