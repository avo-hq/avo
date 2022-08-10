module Avo
  module Licensing
    class ProLicense < License
      def abilities
        [
          :authorization,
          :localization,
          :custom_tools,
          :custom_fields,
          :resource_tools,
          :global_search,
          :enhanced_search_results,
          :searchable_associations,
          :resource_ordering,
          :dashboards,
          :menu_editor,
          :stimulus_js_integration,
          :resource_show_controls,
          :advanced_fields
        ]
      end
    end
  end
end
