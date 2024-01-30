module Avo
  module Fields
    module Concerns
      module ReloadIcon
        extend ActiveSupport::Concern

        included do
          attr_accessor :reload_button
        end

        def reload_icon_enabled?
          # @reload_button = @reload_button.present? ? @reload_button : false
          @reload_button = true
        end
      end
    end
  end
end
