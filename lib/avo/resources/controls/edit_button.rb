module Avo
  module Resources
    module Controls
      class EditButton < BaseControl
        def initialize(**args)
          super(**args)

          @label = args[:label] || I18n.t("avo.edit").capitalize
          if args[:item].present?
            @title = I18n.t("avo.edit_item", item: args[:item]).humanize if title.nil?
          end
        end
      end
    end
  end
end
