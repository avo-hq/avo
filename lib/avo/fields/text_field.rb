module Avo
  module Fields
    class TextField < BaseField
      def initialize(name, **args, &block)
        @defaults = {
          partial_name: "text-field",
          computable: true
        }.merge(@defaults || {})

        super(name, **args, &block)

        @link_to_resource = args[:link_to_resource].present? ? args[:link_to_resource] : false
      end
    end
  end
end
