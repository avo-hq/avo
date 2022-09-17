module Avo
  module Fields
    class HasManyField < HasBaseField
      def initialize(id, **args, &block)
        args[:updatable] = false

        hide_on :all
        show_on :show

        super(id, **args, &block)
      end
    end
  end
end
