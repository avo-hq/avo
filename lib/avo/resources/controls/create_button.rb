module Avo
  module Resources
    module Controls
      class CreateButton < BaseControl
        def initialize(**args)
          super(**args)

          if args[:item].present?
            @label = I18n.t("avo.create_new_item", item: args[:item].humanize(capitalize: false)) if label.nil?
          end
        end
      end
    end
  end
end
