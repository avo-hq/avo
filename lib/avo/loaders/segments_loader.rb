module Avo
  module Loaders
    class SegmentsLoader < Loader
      def use(klass, resource)
        @bag.push klass.new(resource: resource)
      end
    end
  end
end
