module Avo
  module Resources
    module Controls
      class DetachButton < BaseControl
        def initialize(**args)
          super(**args)

          if args[:item].present?
            @title = I18n.t("avo.detach_item", item: args[:item]).humanize if title.nil?
            @confirmation_message = I18n.t("avo.are_you_sure_detach_item", item: args[:item]) if confirmation_message.nil?
          end
        end
      end
    end
  end
end
