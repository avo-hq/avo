module Avo
  module Actions
    class <%= class_name.camelize %> < Action
      def name
        '<%= name.underscore.humanize %>'
      end

      def handle(request, models, fields)
        models.each do |model|
          # Do something with your models.
        end
      end

      fields do
        # Add desired fields here.
      end
    end
  end
end
