require_relative 'field'

module Avocado
  module Fields
    class HeadingField < Field
      def initialize(name, **args, &block)
        @defaults = {
          # updatable: false,
          component: 'heading-field',
          id: 'heading'
        }

        super(name, **args, &block)

        @name = name
        hide_on :index

        @as_html = args[:as_html].present? ? args[:as_html] : false
      end

      def hydrate_resource(model, resource, view)
        {
          as_html: @as_html
        }
      end
    end
  end
end
