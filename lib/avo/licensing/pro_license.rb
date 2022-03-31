module Avo
  module Licensing
    class ProLicense < License
      def abilities
        [
          :authorization,
          :localization,
          :custom_tools,
          :custom_fields,
          :global_search,
          :enhanced_search_results,
          :searchable_associations,
          :resource_ordering,
          :dashboards
        ]
      end
    end
  end
end
