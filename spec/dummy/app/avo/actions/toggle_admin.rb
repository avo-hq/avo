module Avo
  module Actions
    class ToggleAdmin < Action
      self.name = 'Toggle admin'
      self.no_confirmation = true

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
