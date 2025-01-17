module Avo
  module Fields
    class HasManyBaseField < ManyFrameBaseField
      attr_reader :attach_scope,
        :link_to_child_resource,
        :attach_fields

      def initialize(id, **args, &block)
        super(id, **args, &block)

        @attach_scope = args[:attach_scope]
        # Defaults to nil so that if not set falls back to `link_to_child_resource` defined in the resource
        @link_to_child_resource = args[:link_to_child_resource]
        @attach_fields = args[:attach_fields]
      end
    end
  end
end
