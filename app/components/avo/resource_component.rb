class Avo::ResourceComponent < ViewComponent::Base
  def can_create?
    @resource.authorization.authorize_action(:create, raise_exception: false)
  end

  def can_delete?
    @resource.authorization.authorize_action(:destroy, raise_exception: false)
  end

  private

  def simple_relation?
    @reflection.is_a? ::ActiveRecord::Reflection::HasManyReflection
  end
end
