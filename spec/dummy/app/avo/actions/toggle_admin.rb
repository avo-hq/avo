module Avo
  module Actions
    class ToggleAdmin < Action
      def configure
        @name = 'Toggle admin'
        @no_confirmation = true
      end

      def handle(request, models, fields)
        models.each do |model|
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
