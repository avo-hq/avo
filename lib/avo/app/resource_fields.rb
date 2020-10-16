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

        def trix(name, **args, &block)
          @@fields[self].push Avo::Fields::TrixField::new(name, **args, &block)
        end
      end
    end
  end
end
