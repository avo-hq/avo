module Avo
  module Fields
    class HiddenField < TextField
      def initialize(id, **args, &block)
        super

        only_on :forms
      end
    end
  end
end
