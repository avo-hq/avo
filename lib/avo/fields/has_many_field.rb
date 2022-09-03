module Avo
  module Fields
    class HasManyField < HasBaseField
      def initialize(id, **args, &block)
        args[:updatable] = false

        hide_on :all
        show_on Avo.configuration.skip_show_view ? :edit : :show

        super(id, **args, &block)
      end
    end
  end
end
