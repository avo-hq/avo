module Avocado
  module ResourceFields
    class TextField
      # attr_reader :args
      attr_reader :name
      # extend Avocado::ResourceFields::Field

      @@component = 'text-field'

      def initialize(*args)
        # @args = args
        @name = args.first
        # abort args.inspect
        # args
      end

      def fetch_for_resource(resource)
        id = @name.to_s.parameterize

        {
          id: id,
          name: @name,
          component: @@component,
          value: resource[id]
        }
      end
    end
  end
end
