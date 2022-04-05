# frozen_string_literal: true

class Avo::AlertComponent < ViewComponent::Base
  include Avo::ApplicationHelper

  attr_reader :type
  attr_reader :message

  def initialize(type, message)
    @type = type
    @message = message
  end

  def icon
    return "x-circle" if is_error?

    "check-circle"
  end

  def classes
    result = "max-w-lg w-full shadow-lg rounded px-4 py-3 rounded relative border text-white pointer-events-auto"

    result += if is_error?
      " bg-red-400 border-red-700"
    else
      " bg-green-400 border-green-700"
    end

    result
  end

  def is_error?
    type.to_sym == :error
  end
end
