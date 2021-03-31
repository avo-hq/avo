module Avo
  module Fields
    class IdField < BaseField
      def initialize(name, **args, &block)
        default_value = "id"

        if name.nil?
          @name = name = default_value
        elsif !name.is_a?(String) && !name.is_a?(Symbol)
          args_copy = name
          @name = name = default_value
          args = args_copy
        end

        @defaults = {
          id: name.to_sym,
          readonly: true,
          sortable: true,
          partial_name: "id-field"
        }

        hide_on [:edit, :new]

        super(name, **args, &block)

        @link_to_resource = args[:link_to_resource].present? ? args[:link_to_resource] : false
      end
    end
  end
end
