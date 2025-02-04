# frozen_string_literal: true

class Avo::TabContentComponent < Avo::BaseComponent
  prop :tab
  prop :kwargs, kind: :**
end
