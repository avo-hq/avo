# frozen_string_literal: true

class Avo::PanelComponent < ViewComponent::Base
  renders_one :tools
  renders_one :body
  renders_one :bare_content
  renders_one :footer

  def initialize(title: nil, body_classes: nil, data: {}, show_breadcrumbs: true)
    @title = title
    @body_classes = body_classes
    @data = data
    @show_breadcrumbs = show_breadcrumbs
  end

  private

  def data_attributes
    return if @data.blank?

    @data.map do |key, value|
      " data-#{key}=\"#{value}\""
    end.join
  end

  def show_breadcrumbs?
    @show_breadcrumbs
  end
end
