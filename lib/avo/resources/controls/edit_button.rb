module Avo
  module Resources
    module Controls
      class EditButton < BaseControl
        def initialize(**args)
          @label = args[:label] || I18n.t("avo.edit").capitalize
        end
      end
    end
  end
end
