# frozen_string_literal: true

class Avo::Fields::Common::ProgressBarComponent < Avo::BaseComponent
  prop :value, Integer
  prop :display_value, _Boolean, default: false
  prop :value_suffix, _Nilable(String)
  prop :max, Integer, default: 100
  prop :view, Avo::ViewInquirer, reader: :public, default: Avo::ViewInquirer.new(:index).freeze

  delegate :show?, :index?, to: :view
end
