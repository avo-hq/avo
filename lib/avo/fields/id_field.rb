module Avo
  module Fields
    class IdField < BaseField
      attr_reader :link_to_resource

      def initialize(id, **args, &block)
        args[:readonly] = true

        hide_on [:edit, :new]

        super(id, **args, &block)

        add_boolean_prop args, :sortable, true

        @link_to_resource = args[:link_to_resource].present? ? args[:link_to_resource] : false
      end
    end
  end
end
