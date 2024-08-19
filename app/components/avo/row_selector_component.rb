# frozen_string_literal: true

class Avo::RowSelectorComponent < Avo::BaseComponent
  prop :floating, _Boolean, default: false
  prop :size, Symbol, default: :md
end
