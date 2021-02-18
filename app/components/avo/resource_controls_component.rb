# frozen_string_literal: true

class Avo::ResourceControlsComponent < ViewComponent::Base
  attr_reader :resource
  attr_reader :reflection

  def initialize(resource: resource, reflection: reflection)
    @resource = resource
    @reflection = reflection
  end

  def can_detach?
    @reflection.present? &&
    @resource.model.present? &&
    (@reflection.is_a?(::ActiveRecord::Reflection::HasManyReflection) || @reflection.is_a?(::ActiveRecord::Reflection::ThroughReflection))
  end

  def can_delete?
    @resource.authorization.authorize_action(:destroy, raise_exception: false)
  end
end
