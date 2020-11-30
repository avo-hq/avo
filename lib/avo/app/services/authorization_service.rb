module Avo
  class AuthorizationService
    class << self
      def authorize(user, record, action)
        return true if skip_authorization

        begin
          if Pundit.policy user, record
            Pundit.authorize user, record, action
          end
          true
        rescue Pundit::NotAuthorizedError => error
          false
        end
      end

      def authorize_action(user, record, action)
        action = Avo.configuration.authorization_methods.stringify_keys[action.to_s]

        return true if action.nil?

        authorize user, record, action
      end

      def with_policy(user, model)
        return model if skip_authorization

        begin
          Pundit.policy_scope! user, model
        rescue => exception
          model
        end
      end

      def skip_authorization
        Avo::App.license.lacks :authorization
      end
    end
  end
end
