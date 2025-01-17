module Avo
  module Fields
    class HasManyBaseField < ManyFrameBaseField
      attr_accessor :attach_scope

      def initialize(id, **args, &block)
        super(id, **args, &block)

        @attach_scope = args[:attach_scope]
      end
    end
  end
end
