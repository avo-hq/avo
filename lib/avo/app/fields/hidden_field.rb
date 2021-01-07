require_relative 'text_field'

module Avo
  module Fields
    class HiddenField < TextField
      def initialize(name, **args, &block)
        @defaults = {
          component: 'hidden-field',
        }

        super(name, **args, &block)

        only_on [:edit, :new]
      end
    end
  end
end
