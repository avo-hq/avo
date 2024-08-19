# frozen_string_literal: true

class Avo::Items::VisibleItemsComponent < Avo::BaseComponent
  prop :resource, _Nilable(Avo::BaseResource)
  prop :item, _Nilable(Avo::Concerns::IsResourceItem)
  prop :view, _Nilable(Avo::ViewInquirer)
  prop :form, _Nilable(ActionView::Helpers::FormBuilder)
  prop :field_component_extra_args, _Nilable(Hash), default: {}.freeze
end
