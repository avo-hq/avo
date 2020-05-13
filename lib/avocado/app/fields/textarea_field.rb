require_relative './field'

module Avocado
  module Fields
    class TextareaField < Field
      def initialize(*args)
        super

        @component = 'textarea-field'
        @sortable = true
      end
    end
  end
end
