require_relative 'text_field'

module Avo
  module Fields
    class TextareaField < TextField
      def initialize(name, **args, &block)
        @defaults = {
          component: 'textarea-field',
          computable: true,
        }

        super(name, **args, &block)

        hide_on :index

        @meta[:rows] = args[:rows].present? ? args[:rows].to_i : 5
      end
    end
  end
end
