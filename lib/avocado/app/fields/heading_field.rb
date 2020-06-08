require_relative 'field'

module Avocado
  module Fields
    class HeadingField < Field
      def initialize(name, **args, &block)
        @defaults = {
          component: 'heading-field',
        }

        super(name, **args, &block)

        hide_on :index

        @as_html = args[:as_html].present? ? args[:as_html].to_s : ''
      end

      def hydrate_resource(model, resource, view)
        {
          as_html: @as_html
        }
      end
    end
  end
end
