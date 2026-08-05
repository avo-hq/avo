module Avo
  module Fields
    class PasswordField < TextField
      attr_reader :revealable

      def initialize(id, **args, &block)
        show_on :forms

        super

        hide_on :index, :show

        @revealable = args[:revealable].present? ? args[:revealable] : false
      end
    end
  end
end
