module Avo
  module Resources
    module Controls
      class AttachButton < BaseControl
        def initialize(**args)
          super

          if args[:item].present?
            # upcase_first because locales like de put the item first
            # ("%{item} anhängen"); the interpolated name stays as translated.
            @label = I18n.t("avo.attach_item", item: args[:item]).upcase_first if label.nil?
          end
        end
      end
    end
  end
end
