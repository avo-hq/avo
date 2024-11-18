module Pluggy
  module Fields
    class RadioField < Avo::Fields::BaseField
      include Avo::Fields::FieldExtensions::HasIncludeBlank

      attr_reader :options

      def initialize(id, **args, &block)
        super(id, **args, &block)

        add_array_prop args, :options
      end
    end
  end
end
