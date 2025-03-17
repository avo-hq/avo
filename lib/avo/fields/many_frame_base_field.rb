module Avo
  module Fields
    class ManyFrameBaseField < FrameBaseField
      include Avo::Fields::Concerns::IsSearchable

      attr_reader :scope,
        :hide_search_input,
        :discreet_pagination

      def initialize(id, **args, &block)
        args[:updatable] = false

        if args[:nested_on_form]
          if Avo.configuration.resource_default_view.edit?
            only_on [:edit, :new]
          else
            only_on [:show, :edit, :new]
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

      def render_as_nested?
        @nested_on_form && view.in?(%w[new create])
      end
    end
  end
end
