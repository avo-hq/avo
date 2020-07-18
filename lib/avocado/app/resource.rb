require_relative 'resource_fields'
require_relative 'resource_grid_fields'
require_relative 'resource_filters'

module Avocado
  module Resources
    class Resource
      attr_reader :required
      attr_reader :includes
      attr_reader :default_view_type

      class << self
        def hydrate_resource(model, resource, view = :index)
          default_panel_name = "#{resource.name} details"

          resource_with_fields = {
            id: model.id,
            resource_name_singular: resource.resource_name_singular,
            resource_name_plural: resource.resource_name_plural,
            title: model[resource.title],
            fields: [],
            grid_fields: {},
            panels: [{
              name: default_panel_name,
              component: 'panel',
            }]
          }

          grid_fields = resource.get_grid_fields
          grid_fields_by_required_field = grid_fields.map{ |grid_field_id, field| [field.id, grid_field_id] }.to_h

          resource.get_fields.each do |field|
            field_is_required_in_grid_view = grid_fields.map { |grid_field_id, field| field.id }.include?(field.id)
            required_in_current_view = field.send("show_on_#{view.to_s}")

            next unless required_in_current_view or field_is_required_in_grid_view

            furnished_field = field.fetch_for_resource(model, resource, view)

            next if furnished_field.blank?

            furnished_field[:panel_name] = default_panel_name
            furnished_field[:show_on_show] = field.show_on_show

            if field.has_own_panel?
              furnished_field[:panel_name] = field.name.to_s.pluralize
            end

            if field_is_required_in_grid_view
              required_field = grid_fields_by_required_field[field.id]
              resource_with_fields[:grid_fields][required_field] = furnished_field
            end

            if required_in_current_view
              resource_with_fields[:fields] << furnished_field
            end
          end

          resource_with_fields
        end

        def show_path(resource)
          "/resources/#{resource.class.model_name.plural}/#{resource.id}"
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

      def get_grid_fields
        self.class.get_grid_fields
      end

      def available_view_types
        get_grid_fields.length > 0 ? [:grid, :table] : [:table]
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

        [self.search].flatten.each_with_index do |search_by, index|
          query_string = "text(#{search_by}) ILIKE '%#{query}%'"

          if index == 0
            db_query = db_query.where query_string
          else
            db_query = db_query.or(self.model.where query_string)
          end
        end

        db_query.select("#{:id}, #{title} as \"name\"")
      end

      def model
        return @model if @model.present?

        self.class.name.demodulize.safe_constantize
      end

      def attached_file_fields
        get_fields.select do |field|
          [Avocado::Fields::FileField, Avocado::Fields::FilesField].include? field.class
        end
      end

      def has_devise_password
        @has_devise_password or false
      end

      def fill_model(model, params)
        # Map the received params to their actual fields
        fields_by_database_id = self.get_fields.map { |field| [field.database_id(model).to_s, field] }.to_h

        params.each do |key, value|
          field = fields_by_database_id[key]

          next unless field

          model = field.fill_field model, key, value
        end

        model
      end
    end
  end
end
