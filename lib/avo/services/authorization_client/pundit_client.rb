module Avo
  module Services
    module AuthorizationClient
      class PunditClient
        def policy(user, record)
          ::Pundit.policy user, record
        end

        def policy!(user, record)
          ::Pundit.policy! user, record
        rescue ::Pundit::NotDefinedError
          raise AuthorizationService::PolicyNotDefinedError
        end

        def authorize(user, record, action)
          ::Pundit.authorize user, record, action
        rescue ::Pundit::NotAuthorizedError
          raise AuthorizationService::NotAuthorizedError
        end

        def apply_policy!(user, model)
          ::Pundit.policy_scope!(user, model)
        rescue ::Pundit::NotDefinedError
          raise AuthorizationService::PolicyNotDefinedError
        end
      end
    end
  end
end
