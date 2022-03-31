# frozen_string_literal: true

class Avo::ReferrerParamsComponent < ViewComponent::Base
  attr_reader :back_path

  def initialize(back_path: nil)
    @back_path = back_path
  end
end
