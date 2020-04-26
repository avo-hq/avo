module Avocado
  module Resources
    class Service
      extend ResourceFields
      include Resource

      @@name = 'Services'
      @@url = 'services'

      # @name = 'Services'
      # @url = 'services'

      def initialize()
        # @args = args
        # abort @args.inspect
        'hey'
      end

      def name
        @@name
      end

      def url
        @@url
      end

      fields do
        text :ID
        text :Name
      end

      def get_fields
        self.class.get_fields
      end
    end
  end
end

# module Avocado
#   module Resources
#     class Service
#       def initialize
#         @name = 'id'
#       end
#     end
#   end
# end
