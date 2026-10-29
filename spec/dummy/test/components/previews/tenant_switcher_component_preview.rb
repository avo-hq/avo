class TenantSwitcherComponentPreview < ViewComponent::Preview
  Tenant = Struct.new(:id, :name)

  # Tenant Switcher Component
  # -------------------------
  # The account switcher at the bottom of the sidebar, shown when `config.tenancy` uses the session strategy and the
  # user belongs to more than one account. The trigger names the current account; the list marks it.
  def default
    tenants = [Tenant.new(1, "Apple"), Tenant.new(2, "Google"), Tenant.new(3, "A very long account name that truncates")]
    many = (1..12).map { |id| Tenant.new(id, "Account #{id}") }

    render_with_template(
      template: "tenant_switcher_component_preview/default",
      locals: {tenants:, many:}
    )
  end
end
