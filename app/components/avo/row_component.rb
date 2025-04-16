# frozen_string_literal: true

class Avo::RowComponent < Avo::BaseComponent
  renders_one :body

  prop :classes
  prop :data, default: {}.freeze
end
