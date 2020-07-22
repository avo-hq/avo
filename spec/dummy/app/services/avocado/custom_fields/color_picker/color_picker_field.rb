module Avocado
  module CustomFields
    module ColorPicker
      class ColorPickerField < Avocado::Fields::Field
        # def_name 'color_picker'

        def initialize(name, **args, &block)
          @defaults = {
            sortable: true,
            component: 'color-picker-field',
            computable: true,
          }.merge(@defaults || {})

          super(name, **args, &block)
        end
      end
    end
  end
end
