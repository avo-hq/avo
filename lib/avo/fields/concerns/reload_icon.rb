module Avo
  module Fields
    module Concerns
      module ReloadIcon
        extend ActiveSupport::Concern

        def reload_icon_enabled?
          @reload_button
        end
      end
    end
  end
end
