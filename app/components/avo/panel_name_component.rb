# frozen_string_literal: true

class Avo::PanelNameComponent < Avo::BaseComponent
  renders_one :body

  prop :name
  prop :url
  prop :target, default: :self do |value|
    value&.to_sym
  end
  prop :classes, default: ""
end
