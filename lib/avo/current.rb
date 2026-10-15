begin
  require "active_support/isolated_execution_state"
rescue LoadError
  # Older ActiveSupport versions may not expose this file directly.
end
require "active_support/current_attributes"
begin
  require "active_support/code_generator"
rescue LoadError
  # ActiveSupport 6.1 does not have this file.
end
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

  attribute :appearance_settings

  # `active_festivity`'s resolved value, boxed in an Array so a resolved nil is
  # cached too.
  attribute :boxed_active_festivity

  # Which Avo surface this request arrived through: `:ui` for the admin screens, `:api`,
  # `:ai`, `:mcp`. It names the client, not the screen — `view` already means index/show/
  # edit/new, which is a screen within one surface. Consumers that resolve an answer per
  # user can differ per surface without a second declaration.
  attribute :interface

  # Set by the callers that map over every resource with no user in scope — this gem's
  # telemetry, and avo-licensing's debug service. Consumers that restrict what a user may
  # reach read this to opt out explicitly, so the exemption can never be inferred from a
  # nil user (which is a legitimate state on the API surface).
  attribute :enumerating_all_resources

  # Rails 7.1 CurrentAttributes#attribute is only `def attribute(*names)` — no `default:` keyword.
  # `attribute :x, default: {}` is passed as a second positional `{ default: {} }`, so `names.map(&:to_sym)` raises.
  resets do
    self.appearance_settings = {}
    self.interface = :ui
    self.enumerating_all_resources = false
  end

  def initialize
    super
    self.appearance_settings = {}
    self.interface = :ui
    self.enumerating_all_resources = false
  end

  # The active festivity for this request (nil or a festivity symbol). A lambda
  # in `config.festivity` runs on every read of the config, so the layout, the
  # navbar and the helpers all read it through here to run it once per request.
  def active_festivity
    (self.boxed_active_festivity ||= [Avo.configuration.festivity]).first
  end

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
    return false unless user&.respond_to?(Avo.configuration.is_admin_method)

    user.send(Avo.configuration.is_admin_method)
  end

  def user_is_developer?
    return false unless user&.respond_to?(Avo.configuration.is_developer_method)

    user.send(Avo.configuration.is_developer_method)
  end
end
