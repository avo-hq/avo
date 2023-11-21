module Avo
  module Resources
    module Controls
      class SaveButton < BaseControl
        def initialize(**args)
          super(**args)

          @label = args[:label] || I18n.t("avo.save").capitalize
        end
      end
    end
  end
end
