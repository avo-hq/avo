module Avocado
  module Resources
    class Resource
      class << self
        @@fields = {}
        @@filters = {}

        def fields(&block)
          @@fields[self] ||= []
          yield
        end

        def use_filter(filter)
          @@filters[self] ||= []
          @@filters[self].push(filter)
        end

        def get_fields
          @@fields[self]
        end

        def get_filters
          @@filters[self]
        end

        def id(name = nil)
          @@fields[self].push Avocado::Fields::IdField::new(name)
        end

        def text(name)
          @@fields[self].push Avocado::Fields::TextField::new(name)
        end

        def belongs_to(name)
          @@fields[self].push Avocado::Fields::BelongsToField::new(name)
        end

        def has_many(name)
          @@fields[self].push Avocado::Fields::HasManyField::new(name)
        end

        def hydrate_resource(resource, avocado_resource, view = :index)
          default_panel_name = "#{avocado_resource.name} Details"

          resource_with_fields = {
            id: resource.id,
            resource_name_singular: avocado_resource.name,
            resource_name_plural: avocado_resource.name.pluralize,
            title: resource[avocado_resource.title],
            fields: [],
            panels: [{
              name: default_panel_name,
              component: 'panel',
            }]
          }

          avocado_resource.get_fields.each do |field|
            furnished_field = field.fetch_for_resource(resource, view)

            next if furnished_field.blank?

            furnished_field[:panel_name] = default_panel_name

            if ['has-many-field'].include?(furnished_field[:component])
              resource_with_fields[:panels].push({
                name: avocado_resource.name.pluralize,
                component: 'panel'
              })
              furnished_field[:panel_name] = avocado_resource.name.pluralize
            end

            resource_with_fields[:fields] << furnished_field
          end

          resource_with_fields
        end

        def show_path(resource)
          url = resource.class.name.demodulize.downcase.pluralize

          "#{Avocado.root_path}/resources/#{url}/#{resource.id}"
        end

        def index_path(resource_or_class)
          if resource_or_class.class == String
            url = resource_or_class.underscore.pluralize
          else
            url = resource_or_class.class.name.demodulize.underscore.pluralize
          end

          "#{Avocado.root_path}/resources/#{url}"
        end
      end

      def name
        return @name if @name.present?

        self.class.name.demodulize.titlecase
      end

      def underscore_name
        return @name if @name.present?

        self.class.name.demodulize.underscore
      end

      def url
        return @url if @url.present?

        self.class.name.demodulize.underscore.pluralize
      end

      def title
        return @title if @title.present?

        'id'
      end

      def get_fields
        self.class.get_fields
      end

      def get_filters
        self.class.get_filters
      end

      def search
        @search
      end

      def model
        return @model if @model.present?

        self.class.name.demodulize.safe_constantize
      end
    end
  end
end
