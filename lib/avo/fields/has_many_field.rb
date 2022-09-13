module Avo
  module Fields
    class HasManyField < HasBaseField
      def initialize(id, **args, &block)
        args[:updatable] = false

        hide_on :all
        show_on default_view

        super(id, **args, &block)
      end
    end
  end
end
