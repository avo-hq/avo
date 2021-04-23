module Avo
  module Licensing
    class ProLicense < License
      def abilities
        [
          :authorization,
          :custom_tools,
          :custom_fields
        ]
      end
    end
  end
end
