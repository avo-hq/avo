require_relative 'text_field'

module Avocado
  module Fields
    class HiddenField < TextField
      def initialize(name, **args, &block)
        @defaults = {
          component: 'hidden-field',
        }

        super(name, **args, &block)

        hide_on :index
        hide_on :show
      end
    end
  end
end
