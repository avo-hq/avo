# frozen_string_literal: true

class Avo::Fields::Common::KeyValueComponent < Avo::BaseComponent
  include Avo::ApplicationHelper

  attr_reader :view

  prop :field, Avo::Fields::BaseField
  prop :form, _Nilable(ActionView::Helpers::FormBuilder)
  prop :view, Symbol, default: :show do |value|
    value&.to_sym
  end

  def after_initialize
    @view = Avo::ViewInquirer.new(@view)
  end
end
