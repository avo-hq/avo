# frozen_string_literal: true

class Avo::DividerComponent < Avo::BaseComponent
  prop :label, _Nilable(String), :positional, reader: :public
  prop :args, Hash, :**
end
