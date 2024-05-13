# frozen_string_literal: true

class Avo::PanelNameComponent < ViewComponent::Base
  renders_one :body

  def initialize(name:, url: nil, target: :self, classes: "")
    @name = name
    @url = url
    @target = target
    @classes = classes
  end
end
