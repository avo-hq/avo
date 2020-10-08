module Avo
  module Resources
    class Resource
      class << self
        @@filters = {}

        def use_filter(filter)
          @@filters[self] ||= []
          @@filters[self].push(filter)
        end

        def get_filters
          @@filters[self] or []
        end
      end
    end
  end
end
