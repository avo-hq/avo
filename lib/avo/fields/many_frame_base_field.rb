module Avo
  module Fields
    class ManyFrameBaseField < FrameBaseField
      include Avo::Fields::Concerns::IsSearchable

      attr_reader :scope,
        :hide_search_input,
        :discreet_pagination

      def initialize(id, **args, &block)
        args[:updatable] = false

        only_on Avo.configuration.resource_default_view

        super(id, **args, &block)

        @searchable = args[:searchable]
        @scope = args[:scope]
        @hide_search_input = args[:hide_search_input]
        @discreet_pagination = args[:discreet_pagination]
      end
    end
  end
end
