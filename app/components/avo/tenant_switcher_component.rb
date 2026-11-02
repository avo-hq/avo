# frozen_string_literal: true

# Takes over the sidebar's profile row when config.tenancy uses the session strategy, so accounts and profile actions
# share one menu. Each option submits to Avo::TenantsController, which looks the id up through the user's own accounts.
class Avo::TenantSwitcherComponent < Avo::BaseComponent
  TILE_THEMES = (Avo::UI::AvatarComponent::THEMES - ["default"]).freeze

  renders_one :subtitle
  renders_one :status_alert
  renders_one :menu

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

  # AvatarComponent raises on blank initials, and a blank account name must not take the whole sidebar down.
  def initials_for(tenant)
    title_for(tenant).to_s.split.map { |word| word[0] }.join.first(2).presence || "#"
  end

  # Keyed on the id so a rename keeps the color people recognize the account by.
  def theme_for(tenant)
    TILE_THEMES[tenant.id.to_s.sum % TILE_THEMES.size]
  end

  def avatar_for(tenant, size:)
    render Avo::UI::AvatarComponent.new(type: "initials", size:, shape: "square", theme: theme_for(tenant), initials: initials_for(tenant), aria: {hidden: true})
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
    class_names("tenant-switcher__item sidebar-profile__menu-item", "dropdown-menu__item--active": current?(tenant))
  end
end
