# frozen_string_literal: true

module Avo
  class PanelComponent < ViewComponent::Base
    include Avo::ResourcesHelper
    include Avo::ApplicationHelper

    with_content_areas :heading, :tools, :body, :bare_content, :footer

    def initialize(title: nil, body_classes: nil)
      @title = title
      @body_classes = body_classes
    end
  end
end
