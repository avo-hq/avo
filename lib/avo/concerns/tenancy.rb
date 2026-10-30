module Avo
  module Concerns
    # Resolves Avo::Current.tenant on every request from config.tenancy. The id comes from the session or the URL,
    # but the tenant is only ever looked up through the user's `tenants:` relation.
    module Tenancy
      extend ActiveSupport::Concern

      SESSION_KEY = "avo_tenant"

      included do
        helper_method :allowed_tenants
      end

      private

      def set_tenant
        return unless Avo.configuration.tenancy_enabled?

        tenant = if Avo.configuration.session_tenancy?
          tenant_from_session
        else
          find_allowed_tenant(params[:tenant_id]) || raise(ActiveRecord::RecordNotFound)
        end

        # Fail closed: apps often read a nil tenant as "unscoped", so never render the admin without one.
        return render_missing_tenant if tenant.nil?

        Avo::Current.tenant = tenant
        Avo::Current.tenant_id = tenant.id
      end

      def allowed_tenants
        @allowed_tenants ||= Avo::ExecutionContext.new(
          target: Avo.configuration.tenancy[:tenants],
          current_user: _current_user,
          params:,
          request:
        ).handle
      end

      def find_allowed_tenant(id)
        return if id.blank?

        allowed_tenants.find_by(allowed_tenants.primary_key => id)
      end

      # Membership is re-checked on every request, so a removed membership or a tampered id falls back to an
      # account the user still belongs to.
      def tenant_from_session
        stored = session[SESSION_KEY]
        # The tenant is bound to the user who picked it, so signing in as someone else never inherits it.
        stored_id = stored["id"] if stored.is_a?(Hash) && stored["user"] == tenant_session_user

        tenant = find_allowed_tenant(stored_id) || allowed_tenants.first

        if tenant.nil?
          session.delete(SESSION_KEY)
        elsif tenant.id.to_s != stored_id
          store_tenant(tenant)
        end

        tenant
      end

      def store_tenant(tenant)
        session[SESSION_KEY] = {"id" => tenant.id.to_s, "user" => tenant_session_user}
      end

      def tenant_session_user
        user = _current_user
        "#{user.class.name}/#{user.try(:id)}" if user.present?
      end

      def render_missing_tenant
        render "avo/tenants/missing", layout: false, status: :forbidden, formats: [:html]
      end
    end
  end
end
