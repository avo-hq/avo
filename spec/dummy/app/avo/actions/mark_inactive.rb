module Avo
  module Actions
    class MarkInactive < Action
      def name
        'Mark inactive'
      end

      def handle(request, models, fields)
        models.each do |model|
          model.update active: false

          model.notify fields['message'] if fields['notify_user']
        end

        succeed 'Perfect!'
        reload_resources
      end

      fields do
        boolean :notify_user
        textarea :message, default: 'Your account has been marked as inactive.'
      end
    end
  end
end
