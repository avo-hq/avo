module Avo
  module Licensing
    class ProLicense < License
      def abilities
        [
          :authorization,
          :global_search,
          :enhanced_search_results,
          :searchable_associations,
          :resource_ordering,
          :dashboards,
          :menu_editor,
          :customizable_controls,
          :resource_sidebar,
          :advanced_fields
        ]
      end
    end
  end
end
