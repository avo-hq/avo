module Avo
  module Fields
    class ManyFrameBaseField < FrameBaseField
      def initialize(id, **args, &block)
        args[:updatable] = false

        only_on Avo.configuration.resource_default_view

        super(id, **args, &block)
      end
    end
  end
end
