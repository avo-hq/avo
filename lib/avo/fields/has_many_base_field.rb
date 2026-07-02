module Avo
  module Fields
    class HasManyBaseField < ManyFrameBaseField
      attr_reader :attach_scope,
        :link_to_child_resource,
        :attach_fields,
        :attach_using

      def initialize(id, **args, &block)
        super

        @attach_scope = args[:attach_scope]
        # Defaults to nil so that if not set falls back to `link_to_child_resource` defined in the resource
        @link_to_child_resource = args[:link_to_child_resource]
        @attach_fields = args[:attach_fields]
        @attach_using = args[:attach_using] || args[:atach_using]
      end

      def attach_using_checkbox_list?
        @attach_using&.to_sym == :checkbox_list
      end
    end
  end
end
