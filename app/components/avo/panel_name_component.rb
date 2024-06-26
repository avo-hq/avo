# frozen_string_literal: true

class Avo::PanelNameComponent < Avo::BaseComponent
  renders_one :body

  def initialize(name:, url: nil, target: :self, classes: "")
    @name = name
    @url = url
    @target = target
    @classes = classes
  end
end
