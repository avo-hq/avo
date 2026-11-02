class TenantSwitcherComponentPreview < ViewComponent::Preview
  Tenant = Struct.new(:id, :name)

  # Tenant Switcher Component
  # -------------------------
  # Takes over the sidebar's profile row when `config.tenancy` uses the session strategy and the user belongs to more
  # than one account. The trigger names the current account and the user; the menu holds accounts and profile actions.
  def default
    tenants = [Tenant.new(1, "Apple"), Tenant.new(2, "Google"), Tenant.new(3, "A very long account name that truncates")]
    many = (1..12).map { |id| Tenant.new(id, "Account #{id}") }

    render_with_template(
      template: "tenant_switcher_component_preview/default",
      locals: {tenants:, many:}
    )
  end
end
