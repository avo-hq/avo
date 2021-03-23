module Avo
  class ActionModel
    include ActiveModel::Model

    # This class augments a model the action form declaration.
    def initialize(attributes = {})
      set_attr_accessors attributes

      super(attributes)
    end

    private

    def set_attr_accessors(attributes)
      attributes.each do |k, v|
        self.class.class_eval { attr_accessor k }
      end
    end
  end
end
