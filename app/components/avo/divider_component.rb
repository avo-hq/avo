# frozen_string_literal: true

class Avo::DividerComponent < Avo::BaseComponent
  prop :label, kind: :positional
  prop :args, kind: :**
end
