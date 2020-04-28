module Avocado
  module Resources
    class Resource
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
          @@fields[self].push Avocado::Fields::IdField::new(name)
        end

        def text(name)
          @@fields[self].push Avocado::Fields::TextField::new(name)
        end

        def hydrate_resource(resource)

        end

        def show_path(resource)
          url = resource.class.name.demodulize.downcase.pluralize

          "#{Avocado.root_path}/resources/#{url}/#{resource.id}"
        end

        def index_path(resource_or_class)
          if resource_or_class.class == String
            url = resource_or_class.downcase.pluralize
          else
            url = resource_or_class.class.name.demodulize.downcase.pluralize
          end

          "#{Avocado.root_path}/resources/#{url}"
        end
      end

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
    end
  end
end
