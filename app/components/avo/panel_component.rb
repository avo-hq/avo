# frozen_string_literal: true

class Avo::PanelComponent < ViewComponent::Base
  renders_one :tools
  renders_one :body
  renders_one :bare_content
  renders_one :footer

  def initialize(title: nil, body_classes: nil, data: {}, display_breadcrumbs: false, index: nil)
    @title = title
    @body_classes = body_classes
    @data = data
    @display_breadcrumbs = display_breadcrumbs
    @index = index
  end

  private

  def data_attributes
    @data.merge({'panel-index': @index}).map do |key, value|
      " data-#{key}=\"#{value}\""
    end.join
  end

  def display_breadcrumbs?
    @display_breadcrumbs
  end
end
