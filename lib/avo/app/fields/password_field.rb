require_relative 'text_field'

module Avo
  module Fields
    class PasswordField < TextField
      def initialize(name, **args, &block)
        @defaults = {
          component: 'password-field',
        }

        super(name, **args, &block)

        if (args[:only_on].present? || args[:hide_on].present?) && (args[:only_on] == :create || args[:hide_on] == :edit)
          only_on :create
        elsif (args[:only_on].present? || args[:hide_on].present?) && (args[:only_on] == :edit || args[:hide_on] == :create)
          only_on :edit
        else
          only_on :forms
        end
      end
    end
  end
end
