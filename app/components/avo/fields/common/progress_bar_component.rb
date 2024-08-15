# frozen_string_literal: true

class Avo::Fields::Common::ProgressBarComponent < Avo::BaseComponent
  prop :value, Integer
  prop :display_value, _Boolean, default: false
  prop :value_suffix, _Nilable(String)
  prop :max, Integer, default: 100
  prop :view, Avo::ViewInquirer, reader: :public do |value|
    value = :index if value.nil?
    Avo::ViewInquirer.new(value.to_sym)
  end

  delegate :show?, :index?, to: :view
end
