module Avo
  module Fields
    class HiddenField < TextField
      def initialize(id, **args, &block)
        super(id, **args, &block)

        only_on [:edit, :new]
      end
    end
  end
end
