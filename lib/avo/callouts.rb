# frozen_string_literal: true

# Resolves the `self.callouts` a resource declares into the options each
# callout renders with on the current view.
class Avo::Callouts
  TYPES = %i[info success warning error].freeze unless defined?(TYPES)

  def initialize(resource:)
    @resource = resource
  end

  delegate :record, :view, to: :@resource

  def items
    Array.wrap(@resource.class.callouts).filter_map { |callout| parse(callout) }
  end

  private

  def parse(callout)
    unless callout.is_a?(Hash)
      raise ArgumentError, "#{@resource.class} callouts must be Hashes, got #{callout.inspect}"
    end

    return unless callout[:visible].nil? || evaluate(callout[:visible])

    {
      type: type(callout),
      title: evaluate(callout[:title]),
      body: evaluate(callout[:body]),
      icon: evaluate(callout[:icon]),
      url: evaluate(callout[:url]),
      target: evaluate(callout[:target]),
      component: component(callout)
    }
  end

  def type(callout)
    type = evaluate(callout[:type])
    return :info if type.blank?

    type = type.to_sym
    return type if TYPES.include?(type)

    raise ArgumentError, "Unknown callout type #{type.inspect} on #{@resource.class}. Choose from: #{TYPES.join(", ")}"
  end

  def component(callout)
    component = callout[:component] || Avo::CalloutComponent
    component.is_a?(String) ? component.constantize : component
  end

  def evaluate(target)
    Avo::ExecutionContext.new(target:, record:, resource: @resource, view:).handle
  end
end
