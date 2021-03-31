module Avo
  module Fields
    class MarkdownField < BaseField
      def initialize(name, **args, &block)
        @defaults = {
          partial_name: "markdown-field"
        }

        super(name, **args, &block)

        hide_on :index

        @always_show = args[:always_show].present? ? args[:always_show] : false
        @height = args[:height].present? ? args[:height].to_s : "auto"
      end

      def hydrate_field(fields, model, resource, view)
        {
          always_show: @always_show,
          height: @height
        }
      end
    end
  end
end
