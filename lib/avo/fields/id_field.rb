module Avo
  module Fields
    class IdField < BaseField
      attr_reader :link_to_resource

      def initialize(id, **args, &block)
        args[:readonly] = true
        args[:sortable] = true

        hide_on [:edit, :new]

        super(id, **args, &block)

        @link_to_resource = args[:link_to_resource].present? ? args[:link_to_resource] : false
      end
    end
  end
end
