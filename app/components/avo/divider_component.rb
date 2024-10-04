# frozen_string_literal: true

class Avo::DividerComponent < Avo::BaseComponent
  prop :label, nil, :positional
  prop :args, nil, :**
end
