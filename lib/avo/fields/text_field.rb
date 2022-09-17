module Avo
  module Fields
    class TextField < BaseField
      attr_reader :link_to_resource
      attr_reader :as_html
      attr_reader :protocol

      def initialize(id, **args, &block)
        super(id, **args, &block)

        add_boolean_prop args, :link_to_resource
        add_boolean_prop args, :as_html
        add_string_prop args, :protocol
      end
    end
  end
end
