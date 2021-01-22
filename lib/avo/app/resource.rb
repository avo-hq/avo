require_relative 'resource_grid_fields'
require_relative 'resource_filters'
require_relative 'resource_actions'
require_relative 'fields/field'

module Avo
  module Resources
    class Resource
      # include Avo::FieldsLoader
      # extend Avo::FieldsLoader

      attr_writer :model_class
      attr_writer :name

      attr_accessor :id
      attr_accessor :title
      attr_accessor :search
      attr_accessor :includes
      attr_accessor :translation_key
      attr_accessor :default_view_type
      attr_accessor :has_devise_password
      attr_accessor :view
      attr_accessor :model
      attr_accessor :user

      # attr_accessor :model
      # attr_accessor :id
      # attr_accessor :fields
      # attr_accessor :authorization
      # attr_accessor :singular_name
      # attr_accessor :plural_name
      # attr_accessor :includes
      # attr_accessor :path
      # attr_accessor :fields
      # attr_accessor :grid_fields
      # attr_accessor :panels
      # attr_accessor :fields
      attr_accessor :field_loader
      # attr_accessor :request

      alias :field :field_loader
      alias :f :field

      def initialize(request = nil)
        @id = :id
        @title = 'Resource'
        @search = []
        @includes = []
        @translation_key = nil
        @default_view_type = :table
        @has_devise_password = false

        init
        boot_fields request
      end

      def boot_fields(request)
        @field_loader = Avo::FieldsLoader::Loader.new
        fields request
      end

      def hydrate(model: nil, view: nil, user: nil)
        @model = model if model.present?
        @view = view if view.present?
        @user = user if user.present?

        self
      end

      def get_fields(view_type: :table)
        get_field_definitions.select do |field|
          field.send("show_on_#{@view.to_s}")
        end
        .map do |field|
          field.hydrate(model: @model, view: @view, resource: self)
        end
      end

      def get_field_definitions
        @field_loader.fields_bag
      end

      def get_fields_for_all_views
        fields = {
          fields: [],
          grid_fields: [],
        }

        # abort [@view, @user].inspect
        # grid_fields = get_grid_fields
        # grid_fields_by_required_field = grid_fields.map { |grid_field_id, field| [field.id, grid_field_id] }.to_h

        get_field_definitions.each do |field|
          # abort field.inspect
          # field_is_required_in_grid_view = grid_fields.map { |grid_field_id, field| field.id }.include?(field.id)
          required_in_current_view = field.send("show_on_#{@view.to_s}")

          next unless required_in_current_view or field_is_required_in_grid_view

          furnished_field = field.fetch_for_resource(@model, self, @view)

          # next unless field_resource_authorized field, furnished_field, user

          next if furnished_field.blank?

          furnished_field[:panel_name] = default_panel_name
          furnished_field[:show_on_show] = field.show_on_show

          if field.has_own_panel?
            furnished_field[:panel_name] = field.name.to_s.pluralize
          end

          # if field_is_required_in_grid_view
          #   required_field = grid_fields_by_required_field[field.id]
          #   fields[:grid_fields][required_field] = furnished_field
          # end

          if required_in_current_view
            fields[:fields] << furnished_field
          end
        end
        fields
      end

      def default_panel_name
        case @view
        when :show
          I18n.t('avo.resource_details', item: self.name.downcase, title: model_title).upcase_first
        when :edit
          I18n.t('avo.update_item', item: self.name.downcase, title: model_title).upcase_first
        when :new
          I18n.t('avo.create_new_item', item: self.name.downcase).upcase_first
        end
      end

      def panels
        [{
          name: default_panel_name,
        }]
      end

      def model_class
        return @model.class if @model.present?

        self.class.name.demodulize.safe_constantize
      end

      def model_title
        return @model[title] if @model.present?

        name
      end

      def name
        return @name if @name.present?

        return I18n.t(@translation_key, count: 1).capitalize if @translation_key

        self.class.name.demodulize.titlecase
      end

      def singular_name
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

      def attached_file_fields
        get_field_definitions.select do |field|
          [Avo::Fields::FileField, Avo::Fields::FilesField].include? field.class
        end
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

      def file_hash
        content_to_be_hashed = ''

        # resource file hash
        resource_path = Rails.root.join('app', 'avo', 'resources', "#{@resource.name.underscore}.rb").to_s
        if File.file? resource_path
          content_to_be_hashed += File.read(resource_path)
        end

        # policy file hash
        policy_path = Rails.root.join('app', 'policies', "#{@resource.name.underscore}_policy.rb").to_s
        if File.file? policy_path
          content_to_be_hashed += File.read(policy_path)
        end

        Digest::MD5.hexdigest(content_to_be_hashed)
      end

      class << self
        def hydrate_resource(model:, resource:, view: :index, user:)
          case view
          when :show
            panel_name = I18n.t('avo.resource_details', item: resource.name.downcase).upcase_first
          when :edit
            panel_name = I18n.t('avo.edit_item', item: resource.name.downcase).upcase_first
          when :new
            panel_name = I18n.t('avo.create_new_item', item: resource.name.downcase).upcase_first
          end

          resource_with_fields = {
            # id: model.id,
            # authorization: AuthorizationService.new(user, model),
            # singular_name: resource.singular_name,
            # plural_name: resource.plural_name,
            # title: model[resource.title],
            # translation_key: resource.translation_key,
            # path: resource.url,
            # fields: [],
            # grid_fields: {},
            # panels: [{
            #   name: panel_name,
            #   component: 'panel',
            # }],
            # model: model,
            # hash: file_hash(resource), # md5 of the file to break the cache
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

        # def field_resource_authorized(field, furnished_field, user)
        #   if [Avo::Fields::HasManyField, Avo::Fields::HasAndBelongsToManyField].include? field.class
        #     return true if furnished_field[:relationship_model].nil?

        #     AuthorizationService.authorize user, furnished_field[:relationship_model].safe_constantize, Avo.configuration.authorization_methods.stringify_keys['index']
        #   else
        #     true
        #   end
        # end
      end
    end
  end
end
