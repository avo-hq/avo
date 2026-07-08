# frozen_string_literal: true

class Avo::AlertComponent < Avo::BaseComponent
  include Avo::ApplicationHelper

  prop :type, kind: :positional
  prop :message, kind: :positional
  prop :timeout
  prop :description

  def icon
    case variant
    when :danger
      "tabler/outline/circle-x"
    when :warning
      "tabler/outline/exclamation-circle"
    when :info
      "tabler/outline/info-circle"
    when :success
      "tabler/outline/circle-check"
    else
      "tabler/outline/circle"
    end
  end

  def variant
    @variant ||= begin
      return :danger if is_error?
      return :success if is_success?
      return :warning if is_warning?
      return :info if is_info?

      :default
    end
  end

  def is_error?
    normalized_type == :error || normalized_type == :alert
  end

  def is_success?
    normalized_type == :success
  end

  def is_info?
    normalized_type == :notice || normalized_type == :info
  end

  def is_warning?
    normalized_type == :warning
  end

  def is_empty?
    @message.nil?
  end

  private

  def normalized_type
    @normalized_type ||= @type.to_sym
  end

  def timeout
    return @timeout if @timeout.is_a?(Numeric)
    Avo.configuration.alert_dismiss_time
  end

  def keep_open?
    @timeout.try(:to_sym) == :forever
  end
end
