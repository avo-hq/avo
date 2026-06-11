module Avo
  module Fields
    class ManyFrameBaseField < FrameBaseField
      include Avo::Fields::Concerns::IsSearchable
      include Avo::Fields::Concerns::Nested

      attr_reader :scope,
        :hide_search_input,
        :hide_filter_button,
        :discreet_pagination

      def initialize(id, **args, &block)
        args[:updatable] = false

        initialize_nested(**args)

        if @nested[:on]
          if Avo.configuration.resource_default_view.edit?
            only_on Array.wrap(@nested[:on]) + [:edit]
          else
            only_on Array.wrap(@nested[:on]) + [:show]
          end
        else
          only_on Avo.configuration.resource_default_view
        end

        super

        @searchable = args[:searchable]
        @scope = args[:scope]
        @hide_search_input = args[:hide_search_input]
        @hide_filter_button = args[:hide_filter_button]
        @discreet_pagination = args[:discreet_pagination]
      end

      private

      # Expose the association relation as `query` to callable descriptions, on
      # top of the shared `loading_type` flag. Mirrors how `attach_scope` receives
      # `query` in the associations controller. The relation is lazy; SQL runs
      # only if the lambda enumerates or aggregates it (e.g. `query.count`) — so a
      # manual placeholder should branch on `loading_type == :manual` to skip that.
      def description_attributes
        super.merge(query: @record.public_send(association_name))
      end
    end
  end
end
