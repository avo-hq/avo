# frozen_string_literal: true

class Avo::RowComponent < Avo::BaseComponent
  prop :classes, _Nilable(String)
  prop :data, Hash, default: -> { {} }

  renders_one :body
end
