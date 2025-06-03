module Avo
  module Resources
    module Controls
      class BulkEditButton < BaseControl
        def initialize(**args)
          super(**args)

          @label = args[:label] || I18n.t("avo.bulk_update").capitalize
          @title = args[:title] || I18n.t("avo.bulk_update_items").humanize
          @icon = args[:icon] || "avo/edit"
          @style = args[:style] || :primary
          @color = args[:color] || :primary
        end
      end
    end
  end
end
