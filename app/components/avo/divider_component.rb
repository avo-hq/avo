# frozen_string_literal: true

class Avo::DividerComponent < Avo::BaseComponent
  prop :label, _Nilable(String), :positional
  prop :args, Hash, :**
end
