module Avo
  module Licensing
    class ProLicense < License
      def abilities
        [
          :authorization
        ]
      end
    end
  end
end
