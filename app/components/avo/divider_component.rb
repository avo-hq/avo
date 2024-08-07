# frozen_string_literal: true

class Avo::DividerComponent < Avo::BaseComponent
  attr_reader :label

  prop :label, _Nilable(String), :positional
  prop :args, Hash, :**
end
