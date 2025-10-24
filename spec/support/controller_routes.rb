require "test_prof/recipes/rspec/before_all"

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
      include_context "has_admin_user"

      before do
        sign_in admin
      end
    end
  end
end
