# frozen_string_literal: true

class Avo::AlertComponent < ViewComponent::Base
  attr_reader :type
  attr_reader :message

  def initialize(type, message)
    @type = type
    @message = message
  end
end
