module Avo
  module Resources
    module Controls
      class AttachButton < BaseControl
        def initialize(**args)
          super(**args)

          if args[:item].present?
            @label = I18n.t("avo.attach_item", item: args[:item]) if label.nil?
          end
        end
      end
    end
  end
end
