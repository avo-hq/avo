module Avo
  module Fields
    module Concerns
      module ReloadIcon
        extend ActiveSupport::Concern

        included do
          attr_accessor :reloadable
        end

        def reload_icon_enabled?
          Avo::ExecutionContext.new(target: @reloadable).handle
        end
      end
    end
  end
end
