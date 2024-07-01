# frozen_string_literal: true

class Avo::PhotoObject
  def initialize(resource:)
    @resource = resource
  end

  delegate :record, to: :@resource
  delegate :view, to: :@resource

  def options
    @options ||= if @resource.class&.send(key).present?
      @resource.class&.send(key)
    else
      {}
    end
  end

  def value
    return unless options.fetch(:source, nil).present?

    if options[:source].is_a?(Symbol)
      record.send(options[:source])
    elsif options[:source].respond_to?(:call)
      Avo::ExecutionContext.new(target: options[:source], record:, resource: @resource, view:).handle
    end
  end

  def visible_on
    @visible_on ||= Array.wrap(options[:visible_on] || [:show, :forms])
  end

  def visible_in_current_view?
    send(:"visible_on_#{view}?")
  end

  def present?
    value.present?
  end

  def visible_on_index? = visible_in_either?(:index, :display)

  def visible_on_show? = visible_in_either?(:show, :display)

  def visible_on_edit? = visible_in_either?(:edit, :forms)

  def visible_on_new? = visible_in_either?(:new, :forms)

  private

  def visible_in_either?(*options)
    options.map do |option|
      visible_on.include?(option)
    end.uniq.first.eql?(true)
  end
end
