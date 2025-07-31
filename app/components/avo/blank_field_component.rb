# frozen_string_literal: true

class Avo::BlankFieldComponent < Avo::BaseComponent
  # ViewComponent 4.0.0 default initializer does not accept args, so we need to define it since we're calling this with args
  prop :kwargs, kind: :**
end
