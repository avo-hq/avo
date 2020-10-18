module TestHelpers
  module ControllerRoutes
    extend ActiveSupport::Concern
    included do
      routes { Avo::Engine.routes }
    end
  end

  module DisableAuthentication
    extend ActiveSupport::Concern
    included do
      let(:signed_in_admin_user) { create :user, roles: { admin: true } }

      before :each do
        login_as signed_in_admin_user
      end
    end
  end
end
