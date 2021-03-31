module Avo
  module Fields
    class HeadingField < BaseField
      def initialize(name, **args, &block)
        @defaults = {
          updatable: false,
          partial_name: "heading-field",
          id: "heading_" + name.to_s.parameterize.underscore
        }

        super(name, **args, &block)

        hide_on :index

        @meta[:as_html] = args[:as_html].present? ? args[:as_html] : false
      end
    end
  end
end
