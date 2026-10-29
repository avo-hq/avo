# frozen_string_literal: true

# The account switcher at the bottom of the sidebar, rendered when config.tenancy uses the session strategy. Each option
# submits to Avo::TenantsController, which looks the id up through the user's own accounts.
class Avo::TenantSwitcherComponent < Avo::BaseComponent
  prop :tenants do |value|
    value.to_a
  end
  prop :current
  # The page's resource, so a switch lands on that resource's index instead of the Avo root.
  prop :resource

  def render?
    @current.present? && @tenants.size > 1
  end

  def title_for(tenant)
    Avo.configuration.tenant_title(tenant)
  end

  def current?(tenant)
    tenant == @current
  end

  def searchable?
    @tenants.size > 8
  end

  def switch_params(tenant)
    {id: tenant.id, resource: @resource&.route_key}.compact
  end

  def item_classes(tenant)
    class_names("tenant-switcher__item", "dropdown-menu__item--active": current?(tenant))
  end
end
