module Avo
  # The account switcher's endpoint. set_tenant has already re-checked the current tenant by the time this runs.
  class TenantsController < Avo::ApplicationController
    def update
      return head :not_found unless Avo.configuration.session_tenancy?

      tenant = find_allowed_tenant(params[:id])
      # Unknown and foreign ids get the same answer, so the response never tells whether an account exists.
      return head :not_found if tenant.nil?

      clear_tenant_scoped_session
      store_tenant(tenant)

      ActiveSupport::Notifications.instrument("switch_tenant.avo", user: _current_user, from: Avo::Current.tenant, to: tenant)

      redirect_to after_switch_path, status: :see_other
    end

    private

    # Filters and page numbers point into the old account. per_page is a viewer preference, so it stays.
    def clear_tenant_scoped_session
      session.to_hash.each_key do |key|
        session.delete(key) if key.start_with?("/encoded_filters/") || key.end_with?(".page")
      end
    end

    # Never back to the referrer: it may be a record from the old account. The resource is matched against the
    # registered ones, so the redirect can only be one of Avo's own index pages.
    def after_switch_path
      resource = Avo.resource_manager.resources.find { |resource| resource.route_key == params[:resource] } if params[:resource].present?

      resources_path(resource:) || avo.root_path
    end
  end
end
