# frozen_string_literal: true

class Avo::RowComponent < Avo::BaseComponent
  renders_one :body

  prop :classes, _Nilable(String)
  prop :data, Hash, default: {}.freeze
end
