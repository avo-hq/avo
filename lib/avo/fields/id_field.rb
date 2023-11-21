module Avo
  module Fields
    class IdField < BaseField
      attr_reader :link_to_record

      def initialize(id, **args, &block)
        args[:readonly] = true

        hide_on :forms

        super(id, **args, &block)

        add_boolean_prop args, :sortable, true

        @link_to_record = args[:link_to_record].present? ? args[:link_to_record] : false
      end
    end
  end
end
