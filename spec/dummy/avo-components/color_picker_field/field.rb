module Avo
  module Components
    module ColorPickerField
      class Field < Avo::Fields::Field
        field_name 'color_picker'

        def initialize(name, **args, &block)
          @defaults = {
            sortable: true,
            component: 'color-picker-field',
            computable: true,
          }.merge(@defaults || {})

          super(name, **args, &block)

          @allow_non_colors = args[:allow_non_colors]
        end

        def hydrate_field(fields, model, resource, view)
          {
            allow_non_colors: @allow_non_colors
          }
        end
      end
    end
  end
end
