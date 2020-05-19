require_relative 'field'

module Avocado
  module Fields
    class PasswordField < TextField
      def initialize(name, **args, &block)
        @defaults = {
          component: 'password-field'
        }

        super(name, **args, &block)

        only_on :forms
      end
    end
  end
end
