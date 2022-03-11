module Avo
  module Fields
    class HasManyField < HasBaseField
      def initialize(id, **args, &block)
        args[:updatable] = false

        super(id, **args, &block)

        hide_on :all
        show_on :show
      end
    end
  end
end
