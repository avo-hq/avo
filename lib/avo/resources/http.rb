module Avo
  module Resources
    class Http < Base
      class_attribute :endpoint

      class << self
        def authorization
          Avo::Services::AuthorizationService.new Avo::Current.user, nil, policy_class: authorization_policy
        end
      end

      def initialize(view: nil, user: nil, params: nil)
        @view = Avo::ViewInquirer.new(view)
        @user = user
        @params = params
      end

      def authorization(user: nil)
        current_user = user || Avo::Current.user
        Avo::Services::AuthorizationService.new(current_user, policy_class: authorization_policy)
      end

      def type
        :http
      end
    end
  end
end
