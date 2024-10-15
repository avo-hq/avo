module Avo
  module Fields
    class PasswordField < TextField
      attr_reader :reveal

      def initialize(id, **args, &block)
        show_on :forms

        super(id, **args, &block)

        hide_on :index, :show

        @reveal = args[:reveal].present? ? args[:reveal] : false
      end
    end
  end
end
