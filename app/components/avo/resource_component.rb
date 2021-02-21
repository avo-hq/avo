class Avo::ResourceComponent < ViewComponent::Base
  def can_create?
    @resource.authorization.authorize_action(:create, raise_exception: false) && simple_relation?
  end

  def can_delete?
    @resource.authorization.authorize_action(:destroy, raise_exception: false)
  end
end
