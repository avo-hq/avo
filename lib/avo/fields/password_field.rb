module Avo
  module Fields
    class PasswordField < TextField
      def initialize(id, **args, &block)
        show_on :forms

        super(id, **args, &block)

        hide_on [:index, :show]
      end
    end
  end
end
