require_relative 'resource_fields'
require_relative 'resource_grid_fields'
require_relative 'resource_filters'
require_relative 'resource_actions'
require_relative 'fields/field'

module Avo
  module Resources
    class Resource
      attr_reader :required
      attr_reader :includes
      attr_reader :default_view_type

      class << self
        def hydrate_resource(model:, resource:, view: :index, user:)
          default_panel_name = "#{resource.name} details"

          resource_with_fields = {
            id: model.id,
            authorization: get_authorization(user, model),
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
          grid_fields_by_required_field = grid_fields.map { |grid_field_id, field| [field.id, grid_field_id] }.to_h

          resource.get_fields.each do |field|
            field_is_required_in_grid_view = grid_fields.map { |grid_field_id, field| field.id }.include?(field.id)
            required_in_current_view = field.send("show_on_#{view.to_s}")

            next unless required_in_current_view or field_is_required_in_grid_view

            furnished_field = field.fetch_for_resource(model, resource, view)

            next unless field_resource_authorized field, furnished_field, user

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

        def get_authorization(user, model)
          [:create, :update, :show, :destroy].map do |action|
            [action, AuthorizationService::authorize_action(user, model, action)]
          end.to_h
        end

        def field_resource_authorized(field, furnished_field, user)
          if [Avo::Fields::HasManyField, Avo::Fields::HasAndBelongsToManyField].include? field.class
            return true if furnished_field[:relationship_model].nil?

            AuthorizationService.authorize user, furnished_field[:relationship_model].safe_constantize, Avo.configuration.authorization_methods.stringify_keys['index']
          else
            true
          end
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

      def model
        return @model if @model.present?

        underscore_name.to_s.camelize.singularize
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

      def get_actions
        self.class.get_actions
      end

      def search
        @search
      end

      def query_search(query: '', via_resource_name: , via_resource_id:, user:)
        model_class = self.model

        db_query = AuthorizationService.with_policy(user, model_class)

        if via_resource_name.present?
          related_model = App.get_resource_by_name(via_resource_name).model

          db_query = related_model.find(via_resource_id).public_send(self.resource_name_plural.downcase)
        end

        new_query = []

        [self.search].flatten.each_with_index do |search_by, index|
          new_query.push 'or' if index != 0

          new_query.push "text(#{search_by}) ILIKE '%#{query}%'"
        end

        db_query.where(new_query.join(' '))
      end

      def model
        return @model if @model.present?

        self.class.name.demodulize.safe_constantize
      end

      def attached_file_fields
        get_fields.select do |field|
          [Avo::Fields::FileField, Avo::Fields::FilesField].include? field.class
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
