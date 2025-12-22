# frozen_string_literal: true

module Avo
  module UI
    module Tabs
      class ScopeTabsComponent < TabsComponent
        def initialize(**args)
          super(variant: :scope, **args)
        end
      end
    end
  end
end
