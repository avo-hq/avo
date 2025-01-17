module Avo
  module Fields
    class HasManyBaseField < ManyFrameBaseField
      attr_reader :link_to_child_resource,
        :attach_fields,
        :attach_scope
    end
  end
end
