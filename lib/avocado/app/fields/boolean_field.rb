require_relative 'field'

module Avocado
  module Fields
    class BooleanField < Field
      def initialize(name, **args, &block)
        @defaults = {
          sortable: true,
          component: 'boolean-field',
        }

        super(name, **args, &block)

        @trueValue = args[:trueValue].present? ? args[:trueValue] : true
        @falseValue = args[:falseValue].present? ? args[:falseValue] : false
      end

      def fetch_for_resource(model, view = :index)
        fields = super(model, view)

        
        if @block.present?
          fields[:value] = @block.call model, self
        else
          fields[:value] = model[id] == @trueValue
        end

        fields[:trueValue] = @trueValue
        fields[:falseValue] = @falseValue

        fields
      end
    end
  end
end
