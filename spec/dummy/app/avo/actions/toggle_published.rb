module Avo
  module Actions
    class TogglePublished < Action
      def name
        'Toggle published'
      end

      def handle(request, models, fields)
        puts 'handled'.inspect
        'hehe'
      end

      fields do
        select :how, options: { discovery: 'Discovery', ideea: 'Ideea', done: 'Done', 'on hold': 'On hold', cancelled: 'Cancelled' }
        # datetime :when, default: DateTime.now.iso8601(3)
        datetime :when, default: -> (model, resource, fields) { model.created_at }
        boolean :why
      end
    end
  end
end
