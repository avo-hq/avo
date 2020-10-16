require_relative 'text_field'

module Avo
  module Fields
    class PasswordField < TextField
      def initialize(name, **args, &block)
        @defaults = {
          component: 'password-field',
        }

        super(name, **args, &block)

        only_on :forms
      end
    end
  end
end
