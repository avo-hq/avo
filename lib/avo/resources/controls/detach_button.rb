module Avo
  module Resources
    module Controls
      class DetachButton < BaseControl
        def initialize(**args)
          super(**args)

          @label = I18n.t("avo.detach_item", item: title).capitalize
        end
      end
    end
  end
end
