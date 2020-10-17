module Avo
  class AuthorizationService
    class << self
      def controller_actions_map
        {
          actions: 'index?',
          filters: 'index?',
          index: 'index?',
          show: 'show?',
          fields: 'create?',
          edit: 'update?',
          update: 'update?',
          create: 'create?',
          destroy: 'destroy?',
        }.stringify_keys
      end

      def authorize(user, record, action)
        begin
          if Pundit.policy user, record
            Pundit.authorize user, record, action
          end
          true
        rescue Pundit::NotAuthorizedError => error
          false
        rescue NoMethodError => error
          # If the user hasn't defined an action on the Pundit policy yet we'll allow access
          true
        end
      end

      def authorize_action(user, record, action)
        action = controller_actions_map[action.to_s]

        authorize user, record, action
      end
    end
  end
end
