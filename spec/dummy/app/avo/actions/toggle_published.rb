module Avo
  module Actions
    class TogglePublished < Action
      def configure
        @name = 'Toggle post published'
        @message = 'Are you sure, sure?'
        @confirm_text = 'Toggle'
        @cancel_text = "Don't toggle yet"
      end

      def handle(request, models, fields)
        models.each do |model|
          if model.published_at.present?
            model.update published_at: nil
          else
            model.update published_at: DateTime.now
          end
        end

        succeed 'Purrrfect!'
      end

      def fields(request)
        f.boolean :notify_user, default: true
        f.text :message, default: 'Your account has been marked as inactive.'
      end
    end
  end
end
