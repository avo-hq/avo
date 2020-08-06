module Avo
  module Fields
    class HeadingField < Field
      def initialize(name, **args, &block)
        @defaults = {
          updatable: false,
          component: 'heading-field',
          id: 'heading_' + name.to_s.parameterize.underscore,
        }

        super(name, **args, &block)

        hide_on :index

        @as_html = args[:as_html].present? ? args[:as_html] : false
      end

      def hydrate_field(fields, model, resource, view)
        {
          as_html: @as_html
        }
      end
    end
  end
end
