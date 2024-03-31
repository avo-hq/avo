module Avo
  class FieldsExecutionContext < Avo::ExecutionContext
    include Avo::Concerns::HasItems

    def detect_fields
      self.items_holder = Avo::Resources::Items::Holder.new(parent: self)

      instance_exec(&target) if target.present? && target.respond_to?(:call)

      self
    end
  end
end
