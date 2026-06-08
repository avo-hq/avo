module Avo
  module Resources
    module Controls
      class CreateButton < BaseControl
        def initialize(**args)
          super(**args)

          if args[:item].present?
            @label = I18n.t("avo.create_new_item", item: args[:item]) if label.nil?
          end
        end
      end
    end
  end
end
