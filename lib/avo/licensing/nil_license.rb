module Avo
  module Licensing
    class NilLicense < License
      def initialize(response = nil)
        response ||= {
          id: "community",
          valid: true
        }

        super(response)
      end
    end
  end
end
