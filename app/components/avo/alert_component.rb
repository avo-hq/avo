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
    return "heroicons/solid/x-circle" if is_error?
    return "heroicons/solid/exclamation" if is_warning?
    return "heroicons/solid/exclamation-circle" if is_info?
    return "heroicons/solid/check-circle" if is_success?

    "check-circle"
  end

  def classes
    return "hidden" if is_empty?

    result = "max-w-lg w-full shadow-lg rounded px-4 py-3 rounded relative border text-white pointer-events-auto"

    result += if is_error?
      " bg-red-400 border-red-600"
    elsif is_success?
      " bg-green-500 border-green-600"
    elsif is_warning?
      " bg-orange-400 border-orange-600"
    elsif is_info?
      " bg-blue-400 border-blue-600"
    end

    result
  end

  def is_error?
    type.to_sym == :error || type.to_sym == :alert
  end

  def is_success?
    type.to_sym == :success
  end

  def is_info?
    type.to_sym == :notice || type.to_sym == :info
  end

  def is_warning?
    type.to_sym == :warning
  end

  def is_empty?
    message.nil?
  end
end
