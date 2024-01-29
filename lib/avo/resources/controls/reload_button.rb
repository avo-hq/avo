module Avo
  module Resources
    module Controls
      class ReloadButton < BaseControl
        def initialize(**args)
          super(**args)

          if args[:item].present?
            @label = I18n.t("avo.reload_items", item: args[:item].humanize(capitalize: false)) if label.nil?
          end
        end
      end
    end
  end
end
