module Avo
  module Services
    module AuthorizationClients
      class PunditClient
        def authorize(user, record, action, policy_class: nil)
          Pundit.authorize(user, record, action, policy_class: policy_class)
        rescue Pundit::NotDefinedError => error
          raise NoPolicyError.new error.message
        rescue Pundit::NotAuthorizedError => error
          raise NotAuthorizedError.new error.message
        end

        def policy(user, record)
          Pundit.policy(user, record)
        end

        def policy!(user, record)
          Pundit.policy!(user, record)
        rescue Pundit::NotDefinedError => error
          raise NoPolicyError.new error.message
        end

        def apply_policy(user, model, policy_class: nil)
          # Try and figure out the scope from a given policy or auto-detected one
          scope_from_policy_class = scope_for_policy_class(policy_class)

          # If we discover one use it.
          # Else fallback to pundit.
          if scope_from_policy_class.present?
            scope_from_policy_class.new(user, model).resolve
          else
            Pundit.policy_scope!(user, model)
          end
        rescue Pundit::NotDefinedError => error
          raise NoPolicyError.new error.message
        end

        private

        # Fetches the scope for a given policy
        def scope_for_policy_class(policy_class = nil)
          return if policy_class.blank?

          if policy_class.present? && defined?(policy_class::Scope)
            policy_class::Scope
          end
        end
      end
    end
  end
end
