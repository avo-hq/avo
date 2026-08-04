module Avo
  module Resources
    module Controls
      class SaveButton < BaseControl
        def initialize(**args)
          super

          @label = args[:label] || I18n.t(
            "#{args[:resource].translation_key}.save",
            default: I18n.t("avo.save")
          )
        end
      end
    end
  end
end
