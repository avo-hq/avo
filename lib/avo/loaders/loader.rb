module Avo
  module Loaders
    class Loader
      attr_accessor :bag

      def initialize(entity)
        @bag = []

        if entity == :scope && defined?(Avo::Advanced::Scopes::DefaultScope)
          use({class: Avo::Advanced::Scopes::DefaultScope})
        end
      end

      def use(klass)
        @bag.push klass
      end

      def delete(klass)
        @bag.delete klass
      end
    end
  end
end
