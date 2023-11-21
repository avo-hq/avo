module Avo
  module Resources
    module Controls
      class DeleteButton < BaseControl
        def initialize(**args)
          super(**args)

          @label = args[:label] || I18n.t("avo.delete").capitalize
          if args[:item].present?
            @title = I18n.t("avo.delete_item", item: args[:item]).humanize if title.nil?
            @confirmation_message = I18n.t("avo.are_you_sure") if confirmation_message.nil?
          end
        end
      end
    end
  end
end
