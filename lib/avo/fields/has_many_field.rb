module Avo
  module Fields
    class HasManyField < ManyFrameBaseField
      attr_reader :array

      def initialize(id, **args, &block)
        @array = args[:array]

        super
      end

      def translated_name(default:)
        t(translation_key, count: 2, default: default_name).capitalize
      end
    end
  end
end
