module Avo
  module Actions
    class MakeAdmin < Action
      def no_confirmation
        true
      end

      def name
        'Make admin'
      end

      def handle(request, models, fields)
        models.each do |model|
          model.update roles: model.roles.merge!({ "admin": true })
        end

        succeed 'New admin(s) on the board!'
        reload_resources
      end
    end
  end
end
