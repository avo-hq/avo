require_relative 'file_field'

module Avocado
  module Fields
    class ImageField < FileField
      def initialize(name, **args, &block)
        @defaults = {
          component: 'image-field',
        }.merge(@defaults || {})

        super(name, **args, &block)
        @file_field = true
      end

    end
  end
end
