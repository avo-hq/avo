# frozen_string_literal: true

class Avo::Fields::Common::NestedFieldComponent < Avo::BaseComponent
  prop :field
  prop :view
  prop :form
  prop :kwargs, kind: :**

  def render?
    Avo.plugin_manager.installed?("avo-advanced")
  end
end
