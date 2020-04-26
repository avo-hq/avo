module Avocado
  module Resources
    class Resource
      def get_fields
        self.class.get_fields
      end

      def name
        return @name if @name.present?

        self.class.name.demodulize
      end

      def url
        return @url if @url.present?

        self.class.name.demodulize.downcase.pluralize
      end

      def title
        return @title if @title.present?

        'id'
      end

      class << self
        @@fields = {}

        def fields(&block)
          @@fields[self] ||= []
          yield
        end

        def get_fields
          @@fields[self]
        end

        def id(name)
          @@fields[self].push Avocado::ResourceFields::IdField::new(name)
        end

        def text(name)
          @@fields[self].push Avocado::ResourceFields::TextField::new(name)
        end

        def hydrate_resource(resource)

        end
      end
    end
  end
end
