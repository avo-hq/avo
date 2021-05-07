module Avo
  module Licensing
    class ProLicense < License
      def abilities
        [
          :authorization,
          :custom_tools,
          :custom_fields,
          :global_search,
          :enhanced_search_results
        ]
      end
    end
  end
end
