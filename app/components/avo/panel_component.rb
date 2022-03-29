# frozen_string_literal: true

class Avo::PanelComponent < ViewComponent::Base
  attr_reader :title

  RIGHT_ALIGNED_BUTTONS_BREAKPOINT = "xl"

  renders_one :tools
  renders_one :body
  renders_one :bare_content
  renders_one :footer

  def initialize(title: nil, description: nil, body_classes: nil, data: {}, display_breadcrumbs: false, index: nil)
    @title = title
    @description = description
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
    @display_breadcrumbs == true && Avo.configuration.display_breadcrumbs == true
  end

  def description
    return @description if @description.present?

    ""
  end

  def render_header?
    @title.present? || description.present? || tools.present? || display_breadcrumbs?
  end

  def bp
    RIGHT_ALIGNED_BUTTONS_BREAKPOINT
  end
end
