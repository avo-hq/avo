# frozen_string_literal: true

class Avo::PanelNameComponent < Avo::BaseComponent
  renders_one :body

  prop :name, _Nilable(_Union(_String, _Integer))
  prop :url, _Nilable(String)
  prop :target, Symbol, default: :self do |value|
    value&.to_sym
  end
  prop :classes, String, default: ""
end
