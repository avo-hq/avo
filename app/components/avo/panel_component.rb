# frozen_string_literal: true

class Avo::PanelComponent < ViewComponent::Base
  with_content_areas :tools, :body, :bare_content, :footer

  def initialize(title: nil, body_classes: nil)
    @title = title
    @body_classes = body_classes
  end
end
