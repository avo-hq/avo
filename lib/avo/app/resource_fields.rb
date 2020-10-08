module Avo
  module Resources
    class Resource
      class << self
        @@fields = {}

        def fields(&block)
          @@fields[self] ||= []
          yield
        end

        def get_fields
          @@fields[self] or []
        end

        def add_field(resource, field)
          @@fields[resource].push field
        end
      end
    end
  end
end
