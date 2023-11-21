# frozen_string_literal: true

class Avo::Fields::Common::ProgressBarComponent < ViewComponent::Base
  attr_reader :value
  attr_reader :display_value
  attr_reader :value_suffix
  attr_reader :max
  attr_reader :view

  def initialize(value:, display_value: false, value_suffix: nil, max: 100, view: "index")
    @value = value
    @display_value = display_value
    @value_suffix = value_suffix
    @max = max
    @view = Avo::ViewInquirer.new(view)
  end

  delegate :show?, :index?, to: :view
end
