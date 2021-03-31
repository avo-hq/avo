module Avo
  module Fields
    class NumberField < TextField
      def initialize(name, **args, &block)
        @defaults = {
          partial_name: "number-field",
          computable: true
        }

        super(name, **args, &block)

        @meta = {
          min: args[:min].present? ? args[:min].to_f : nil,
          max: args[:max].present? ? args[:max].to_f : nil,
          step: args[:step].present? ? args[:step].to_f : nil
        }
      end
    end
  end
end
