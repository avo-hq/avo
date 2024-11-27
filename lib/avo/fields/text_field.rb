module Avo
  module Fields
    class TextField < BaseField
      attr_reader :link_to_record
      attr_reader :as_html
      attr_reader :protocol
      attr_reader :copyable

      def initialize(id, **args, &block)
        super(id, **args, &block)

        add_boolean_prop args, :link_to_record
        add_boolean_prop args, :as_html
        add_string_prop args, :protocol
        add_boolean_prop args, :copyable
      end
    end
  end
end
