module Avo
  module Services
    module AuthorizationClients
      class PunditClient
        def authorize(user, record, action, policy_class: nil)
          Pundit.authorize(user, record, action, policy_class: policy_class)
        rescue Pundit::NotDefinedError
          raise NoPolicyError
        rescue Pundit::NotAuthorizedError
          raise NotAuthorizedError
        end

        def policy(user, record)
          Pundit.policy(user, record)
        end

        def policy!(user, record)

          Pundit.policy!(user, record)
        rescue Pundit::NotDefinedError
          raise NoPolicyError
        end

        def apply_policy(user, model, policy_class: nil)
          if policy_class
            policy_class::Scope.new(user, model).resolve
          else
            Pundit.policy_scope! user, model
          end
        rescue Pundit::NotDefinedError
          raise NoPolicyError
        end
      end
    end
  end
end
