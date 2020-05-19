require_relative './field'

module Avocado
  module Fields
    class PasswordField < TextField
      include IsReadonly

      def initialize(name, **args, &block)
        super(name, **args, &block)

        @component = 'password-field'

        only_on :forms
      end
    end
  end
end
