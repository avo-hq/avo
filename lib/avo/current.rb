class Avo::Current < ActiveSupport::CurrentAttributes
  attribute :app
  attribute :license
  attribute :context
  attribute :user
  attribute :view_context
  attribute :error_manager
  attribute :resource_manager
  attribute :tool_manager
  attribute :plugin_manager
  attribute :locale

  # The tenant attributes are here so the user can add them on their own will
  attribute :tenant_id
  attribute :tenant

  # Protect from error #<RuntimeError: Missing rack.input> when request is ActionDispatch::Request.empty
  def params
    request.params
  rescue
    {}
  end

  def request
    view_context&.request || ActionDispatch::Request.empty
  end

  def user_is_admin?
    return false unless user && user.respond_to?(Avo.configuration.is_admin_method)

    user.send(Avo.configuration.is_admin_method)
  end

  def user_is_developer?
    return false unless user && user.respond_to?(Avo.configuration.is_developer_method)

    user.send(Avo.configuration.is_developer_method)
  end
end
