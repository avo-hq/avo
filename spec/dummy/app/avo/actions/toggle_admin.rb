module Avo
  module Actions
    class ToggleAdmin < Action
      def no_confirmation
        true
      end

      def name
        'Toggle admin'
      end

      def handle(request, models, fields)
        models.each do |model|
          puts ['model.roles->', model.roles].inspect
          if model.roles['admin']
            model.update roles: model.roles.merge!({ "admin": false })
          else
            model.update roles: model.roles.merge!({ "admin": true })
          end
        end

        succeed 'New admin(s) on the board!'
      end
    end
  end
end
