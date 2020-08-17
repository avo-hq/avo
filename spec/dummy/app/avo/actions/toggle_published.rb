module Avo
  module Actions
    class TogglePublished < Action
      def name
        'Toggle post published'
      end

      def message
        'Are you sure, sure?'
      end

      def handle(request, models, fields)
        models.each do |model|
          if model.published_at.present?
            model.update published_at: nil
          else
            model.update published_at: DateTime.now
          end
        end

        succeed 'Perfect!'
        redirect '/resources/posts'
      end

      def confirm_text
        'Toggle'
      end

      def cancel_text
        "Don't toggle yet"
      end
    end
  end
end
