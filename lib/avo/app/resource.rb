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

      # attr_accessor :model
      # attr_accessor :id
      # attr_accessor :authorization
      # attr_accessor :singular_name
      # attr_accessor :plural_name
      # attr_accessor :title
      # attr_accessor :translation_key
      # attr_accessor :path
      # attr_accessor :fields
      # attr_accessor :grid_fields
      # attr_accessor :panels

      class << self
        def hydrate_resource(model:, resource:, view: :index, user:)
          case view
          when :show
            panel_name = I18n.t 'avo.resource_details', item: resource.name.downcase.upcase_first
          when :edit
            panel_name = I18n.t('avo.edit_item', item: resource.name.downcase).upcase_first
          when :new
            panel_name = I18n.t('avo.create_new_item', item: resource.name.downcase).upcase_first
          end

          resource_with_fields = {
            id: model.id,
            authorization: AuthorizationService.new(user, model),
            singular_name: resource.singular_name,
            plural_name: resource.plural_name,
            title: model[resource.title],
            translation_key: resource.translation_key,
            path: resource.url,
            fields: [],
            grid_fields: {},
            panels: [{
              name: panel_name,
              component: 'panel',
            }],
            model: model,
            hash: file_hash(resource), # md5 of the file to break the cache
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

            furnished_field[:panel_name] = panel_name
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

          # abort self.inspect
          # self.new resource_with_fields
          resource_with_fields
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
          [:new, :edit, :update, :show, :destroy].map do |action|
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

        def file_hash(resource)
          content_to_be_hashed = ''
          # resource file hash
          resource_path = Rails.root.join('app', 'avo', 'resources', "#{resource.name.underscore}.rb").to_s
          if File.file? resource_path
            content_to_be_hashed += File.read(resource_path)
          end

          # policy file hash
          policy_path = Rails.root.join('app', 'policies', "#{resource.name.underscore}_policy.rb").to_s
          if File.file? policy_path
            content_to_be_hashed += File.read(policy_path)
          end

          Digest::MD5.hexdigest(content_to_be_hashed)
        end
      end

      # def initialize(hash)
      #   hash.each {|k,v| public_send("#{k}=",v)}
      # end

      def name
        return @name if @name.present?

        return I18n.t(@translation_key, count: 1).capitalize if @translation_key

        self.class.name.demodulize.titlecase
      end

      def singular_name
        return I18n.t(@translation_key, count: 1).capitalize if @translation_key

        name
      end

      def plural_name
        return I18n.t(@translation_key, count: 2).capitalize if @translation_key

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

      def model_path
        # Rails.application.routes.url_helpers.resource_path(model.name.underscore.pluralize)
        Avo::Engine.routes.url_helpers.resource_path(model.name.underscore.pluralize)
      end

      def title
        return @title if @title.present?

        'id'
      end

      def translation_key
        @translation_key
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

          db_query = related_model.find(via_resource_id).public_send(self.plural_name.downcase)
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

      def authorization(user)
        AuthorizationService.new(user, model)
      end
    end
  end
end
