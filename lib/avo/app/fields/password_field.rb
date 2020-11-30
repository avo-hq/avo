require_relative 'text_field'

module Avo
  module Fields
    class PasswordField < TextField
      def initialize(name, **args, &block)
        @defaults = {
          component: 'password-field',
        }

        show_on :forms

        super(name, **args, &block)

        hide_on [:index, :show]
      end
    end
  end
end
