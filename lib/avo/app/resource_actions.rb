module Avo
  module Resources
    class Resource
      class << self
        @@actions = {}

        def use_action(action)
          @@actions[self] ||= []
          @@actions[self].push(action)
        end

        def get_actions
          @@actions[self] or []
        end
      end
    end
  end
end
