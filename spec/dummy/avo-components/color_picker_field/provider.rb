
module Avo
  module Components
    module ColorPickerField
      class Provider
        ROOT_PATH = Pathname.new(File.join(__dir__))

        def self.boot
          Avo::App.initializing do
            Avo::App.script 'color_picker_field.js', "#{File.dirname(__FILE__)}/frontend"
            Avo::App.load_field :color_picker, Avo::Components::ColorPickerField::Field
          end

        end
      end
    end
  end
end
