module Avo
  module Fields
    module Concerns
      module ReloadIcon
        extend ActiveSupport::Concern

        include do
          attr_accessor :reload_button
        end

        def reload_icon_enabled?
          @reload_button
        end
      end
    end
  end
end
