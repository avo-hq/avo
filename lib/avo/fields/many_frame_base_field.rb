module Avo
  module Fields
    class ManyFrameBaseField < FrameBaseField
      include Avo::Fields::Concerns::IsSearchable
      include Avo::Fields::Concerns::Nested

      attr_reader :scope,
        :hide_search_input,
        :discreet_pagination

      def initialize(id, **args, &block)
        args[:updatable] = false

        initialize_nested **args

        if @nested[:on]
          if Avo.configuration.resource_default_view.edit?
            only_on Array.wrap(@nested[:on]) + [:edit]
          else
            only_on Array.wrap(@nested[:on]) + [:show]
          end
        else
          only_on Avo.configuration.resource_default_view
        end

        super(id, **args, &block)

        @searchable = args[:searchable]
        @scope = args[:scope]
        @hide_search_input = args[:hide_search_input]
        @discreet_pagination = args[:discreet_pagination]
      end
    end
  end
end
