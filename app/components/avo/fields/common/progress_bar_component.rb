# frozen_string_literal: true

class Avo::Fields::Common::ProgressBarComponent < Avo::BaseComponent
  prop :value, Integer, reader: :public
  prop :display_value, _Boolean, default: false, reader: :public
  prop :value_suffix, _Nilable(String), reader: :public
  prop :max, Integer, default: 100, reader: :public
  prop :view, Symbol, default: :index, reader: :public do |value|
    value&.to_sym
  end

  def after_initialize
    @view = Avo::ViewInquirer.new(view)
  end

  delegate :show?, :index?, to: :view
end
