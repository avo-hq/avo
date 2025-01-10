module Avo
  module Fields
    class HasManyField < HasBaseField
      attr_reader :array

      def initialize(id, **args, &block)
        args[:updatable] = false
        @array = args[:array]

        only_on Avo.configuration.resource_default_view

        super(id, **args, &block)
      end

      def translated_name(default:)
        t(translation_key, count: 2, default: default_name).capitalize
      end
    end
  end
end
