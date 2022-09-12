return unless Avo.configuration.authorization_client == :action_policy

# ActionPolicy monkeypatches Rails behavior, so we'll only load it if we're using it.
require 'action_policy'

module Avo
  module Services
    module AuthorizationClient
      class ActionPolicyClient
        include ::ActionPolicy::Behaviour

        authorize :user
        attr_reader :user

        def policy(user, record)
          policy!(user, record)
        rescue AuthorizationService::PolicyNotDefinedError
          nil
        end

        def policy!(user, record)
          @user = user
          policy_for(record: record)
        rescue ActionPolicy::NotFound
          raise AuthorizationService::PolicyNotDefinedError
        end

        def authorize(user, record, action)
          @user = user
          authorize! record, to: action
        rescue ActionPolicy::Unauthorized
          raise AuthorizationService::NotAuthorizedError
        end

        def apply_policy!(user, model)
          policy!(user, model).apply_scope(model, type: :avo_scope)
        rescue ActionPolicy::NotFound
          raise AuthorizationService::PolicyNotDefinedError
        end
      end
    end
  end
end
