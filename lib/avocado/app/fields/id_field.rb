require_relative 'field'

module Avocado
  module Fields
    class IdField < Field
      def initialize(name, **args, &block)
        @defaults = {
          readonly: true,
          sortable: true,
          component: 'id-field'
        }

        hide_on :edit

        super(name, **args, &block)
      end
    end
  end
end
