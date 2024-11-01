# frozen_string_literal: true

class Avo::Fields::Common::ProgressBarComponent < Avo::BaseComponent
  prop :value
  prop :display_value, default: false
  prop :value_suffix
  prop :max, default: 100
  prop :view, reader: :public, default: Avo::ViewInquirer.new(:index).freeze

  delegate :show?, :index?, to: :view
end
