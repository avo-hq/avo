module Avo
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
          @@grid_fields[self][:preview] = Avo::GridFields::PreviewField::new(name, **args, &block)
        end

        def title(name, **args, &block)
          @@grid_fields[self][:title] = Avo::GridFields::TitleField::new(name, **args, &block)
        end

        def body(name, **args, &block)
          @@grid_fields[self][:body] = Avo::GridFields::BodyField::new(name, **args, &block)
        end
      end
    end
  end
end
