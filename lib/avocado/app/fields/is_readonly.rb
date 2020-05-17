
module Avocado
  module Fields
    module IsReadonly
      def initialize(name, **args, &block)
        @readonly = true
      end

      def fetch_for_resource(model, view = :index)
        fields = super(model, view)

        fields[:readonly] = @readonly

        fields
      end
    end
  end
end