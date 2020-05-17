require_relative './field'

module Avocado
  module Fields
    class TextareaField < Field
      def initialize(name, **args, &block)
        super(name, **args, &block)

        @component = 'textarea-field'
        @sortable = true
        @rows = args[:rows].present? ? args[:rows].to_i : 5
      end

      def fetch_for_resource(model, view = :index)
        fields = super(model, view)

        fields[:rows] = @rows
        fields[:value] = @block.call model, self if @block.present?

        fields
      end
    end
  end
end
