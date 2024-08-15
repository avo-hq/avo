# frozen_string_literal: true

class Avo::Fields::Common::KeyValueComponent < Avo::BaseComponent
  include Avo::ApplicationHelper

  prop :field, Avo::Fields::BaseField
  prop :form, _Nilable(ActionView::Helpers::FormBuilder)
  prop :view, Avo::ViewInquirer do |value|
    value = :show if value.nil?
    Avo::ViewInquirer.new(value.to_sym)
  end
end
