module Avo
  module Fields
    module Concerns
      module ReloadIcon
        extend ActiveSupport::Concern

        included do
          attr_accessor :reload_button
        end

        def reload_icon_enabled?
          Avo::ExecutionContext.new(target: @reload_button).handle
        end
      end
    end
  end
end
