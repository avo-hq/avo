require 'test_prof/recipes/rspec/before_all'

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
      before_all do
        login_as admin
      end
    end
  end

  module DisableHQRequest
    extend ActiveSupport::Concern
    included do
      before_all do
        stub_pro_license_request
      end
    end
  end
end
