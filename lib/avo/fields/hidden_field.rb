module Avo
  module Fields
    class HiddenField < TextField
      def initialize(id, **args, &block)
        super(id, **args, &block)

        only_on :forms
      end
    end
  end
end
