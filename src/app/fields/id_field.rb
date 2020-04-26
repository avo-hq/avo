module Avocado
  module ResourceFields
    class IdField
      # extend Avocado::ResourceFields::Field
      attr_reader :name

      @@component = 'id-field'
      @@can_be_updated = false

      def initialize(*args)
        @name = args.first
      end

      def fetch_for_resource(resource)
        id = @name.to_s.parameterize

        {
          id: id,
          name: @name,
          component: @@component,
          value: resource[id],
          can_be_updated: @@can_be_updated
        }
      end
    end
  end
end
