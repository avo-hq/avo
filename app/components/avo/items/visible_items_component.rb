# frozen_string_literal: true

class Avo::Items::VisibleItemsComponent < Avo::BaseComponent
  prop :resource
  prop :item
  prop :view
  prop :form
  prop :reflection, default: nil
  prop :field_component_extra_args, default: {}.freeze
end
