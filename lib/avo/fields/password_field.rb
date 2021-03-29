module Avo
  module Fields
    class PasswordField < TextField
      def initialize(name, **args, &block)
        @defaults = {
          partial_name: "password-field"
        }

        show_on :forms

        super(name, **args, &block)

        hide_on [:index, :show]
      end
    end
  end
end
