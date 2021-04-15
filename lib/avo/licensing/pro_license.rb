module Avo
  module Licensing
    class ProLicense < License
      def abilities
        [
          :authorization,
          :custom_tools
        ]
      end
    end
  end
end
