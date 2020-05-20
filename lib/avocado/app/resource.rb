module Avocado
  module Resources
    class Resource
      attr_reader :required
      attr_reader :includes

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
          @@fields[self] or []
        end

        def get_filters
          @@filters[self] or []
        end

        def id(name = 'ID', **args)
          @@fields[self].push Avocado::Fields::IdField::new(name, **args)
        end

        def text(name, **args, &block)
          @@fields[self].push Avocado::Fields::TextField::new(name, **args, &block)
        end

        def password(name, **args, &block)
          @@fields[self].push Avocado::Fields::PasswordField::new(name, **args, &block)
        end

        def textarea(name, **args, &block)
          @@fields[self].push Avocado::Fields::TextareaField::new(name, **args, &block)
        end

        def number(name, **args, &block)
          @@fields[self].push Avocado::Fields::NumberField::new(name, **args, &block)
        end

        def boolean(name, **args, &block)
          @@fields[self].push Avocado::Fields::BooleanField::new(name, **args, &block)
        end

        def belongs_to(name, **args)
          @@fields[self].push Avocado::Fields::BelongsToField::new(name, **args)
        end

        def has_many(name, **args)
          @@fields[self].push Avocado::Fields::HasManyField::new(name, **args)
        end

        def hydrate_resource(model, resource, view = :index)
          default_panel_name = "#{resource.name} Details"

          resource_with_fields = {
            id: model.id,
            resource_name_singular: resource.resource_name_singular,
            resource_name_plural: resource.resource_name_plural,
            title: model[resource.title],
            fields: [],
            panels: [{
              name: default_panel_name,
              component: 'panel',
            }]
          }

          resource.get_fields.each do |field|
            next unless field.send "show_on_#{view.to_s}"

            furnished_field = field.fetch_for_resource(model, resource, view)

            next if furnished_field.blank?

            furnished_field[:panel_name] = default_panel_name
            furnished_field[:show_on_show] = field.show_on_show

            if ['has-many-field'].include?(furnished_field[:component])
              furnished_field[:panel_name] = field.name.to_s.pluralize
            end

            resource_with_fields[:fields] << furnished_field
          end

          resource_with_fields
        end

        def show_path(resource)
          url = resource.class.name.demodulize.downcase.pluralize

          "/resources/#{url}/#{resource.id}"
        end

        def index_path(resource_or_class)
          if resource_or_class.class == String
            url = resource_or_class.underscore.pluralize
          else
            url = resource_or_class.class.name.demodulize.underscore.pluralize
          end

          "/resources/#{url}"
        end
      end

      def name
        return @name if @name.present?

        self.class.name.demodulize.titlecase
      end

      def resource_name_singular
        name
      end

      def resource_name_plural
        name.pluralize
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

      def query_search(query: '', via_resource_name: , via_resource_id:)
        db_query = self.model

        if via_resource_name.present?
          related_resource = App.get_resource_by_name(via_resource_name)
          related_model = related_resource.model
          db_query = related_model.find(via_resource_id).public_send(self.resource_name_plural.downcase)
        end

        self.search.each_with_index do |search_by, index|
          query_string = "text(#{search_by}) ILIKE '%#{query}%'"

          if index == 0
            db_query = db_query.where query_string
          else
            db_query = db_query.or(self.model.where query_string)
          end
        end

        db_query
      end

      def model
        return @model if @model.present?

        self.class.name.demodulize.safe_constantize
      end
    end
  end
end
