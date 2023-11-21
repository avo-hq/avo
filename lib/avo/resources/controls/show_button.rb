module Avo
  module Resources
    module Controls
      class ShowButton < BaseControl
        def initialize(**args)
          super(**args)

          if args[:item].present?
            @title = I18n.t("avo.view_item", item: args[:item]).humanize if title.nil?
          end
        end
      end
    end
  end
end
