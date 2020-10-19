module Avo
  class AuthorizationService
    class << self
      def controller_actions_map
        {
          actions: 'index?',
          index: 'index?',
          show: 'show?',
          new: 'new?',
          edit: 'edit?',
          update: 'update?',
          create: 'create?',
          destroy: 'destroy?',
          search: nil,
          resource_search: nil,
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
        end
      end

      def authorize_action(user, record, action)
        action = controller_actions_map[action.to_s]

        return true if action.nil?

        authorize user, record, action
      end
    end
  end
end
