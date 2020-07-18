module Avocado
  module Resources
    class Resource
      class << self
        @@grid_fields = {}

        def grid(&block)
          @@grid_fields[self] ||= {}
          yield
        end

        def get_grid_fields
          @@grid_fields[self] or {}
        end

        def preview(name, **args, &block)
          @@grid_fields[self][:preview] = Avocado::GridFields::PreviewField::new(name, **args, &block)
        end

        def title(name, **args, &block)
          @@grid_fields[self][:title] = Avocado::GridFields::TitleField::new(name, **args, &block)
        end

        def body(name, **args, &block)
          @@grid_fields[self][:body] = Avocado::GridFields::BodyField::new(name, **args, &block)
        end
      end
    end
  end
end
