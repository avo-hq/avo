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

      # Expose the association relation as `query` to description lambdas,
      # mirroring how `attach_scope` receives `query` in the associations controller.
      def description_attributes
        {query: @record.public_send(association_name)}
      end
    end
  end
end
