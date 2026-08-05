module Avo
  module Resources
    module Controls
      class CreateButton < BaseControl
        def initialize(**args)
          super

          if args[:item].present?
            # upcase_first, not humanize: the item is already the sentence form
            # (translation verbatim, generated fallback lowercased), and locales
            # like de put it first ("%{item} hinzufügen"), so only the sentence's
            # initial is cased -- the interpolated name stays as translated.
            @label = I18n.t("avo.create_new_item", item: args[:item]).upcase_first if label.nil?
          end
        end
      end
    end
  end
end
