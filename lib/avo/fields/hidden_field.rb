module Avo
  module Fields
    class HiddenField < TextField
      def initialize(name, **args, &block)
        @defaults = {
          partial_name: "hidden-field"
        }

        super(name, **args, &block)

        only_on [:edit, :new]
      end
    end
  end
end
