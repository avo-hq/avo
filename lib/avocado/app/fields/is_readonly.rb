require_relative 'field_helper'

module Avocado
  module Fields
    module IsReadonly
      def initialize(name, **args, &block)
        @field_args = { readonly: false }

        super(name, **args, &block)
      end

      def fetch_for_resource(model, view = :index)
        fields = super(model, view)

        fields[:readonly] = @readonly or false

        fields
      end
    end
  end
end