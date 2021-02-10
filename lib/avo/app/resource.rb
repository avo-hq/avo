require_relative 'resource_grid_fields'
require_relative 'resource_filters'
require_relative 'resource_actions'
require_relative 'fields/field'

module Avo
  module Resources
    class Resource
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
      attr_accessor :field_loader
      attr_accessor :params

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

        configure
        boot_fields request
      end

      def boot_fields(request)
        @field_loader = Avo::FieldsLoader::Loader.new
        fields request
      end

      def hydrate(model: nil, view: nil, user: nil, params: nil)
        @model = model if model.present?
        @view = view if view.present?
        @user = user if user.present?
        @params = params if params.present?

        self
      end

      def get_fields(panel: nil, view_type: :table)
        fields = get_field_definitions.select do |field|
          field.send("show_on_#{@view.to_s}")
        end

        case view_type.to_sym
        when :table
          fields = fields.select do |field|
            field.show_on_grid.blank?
          end
          .select do |field|
            field.can_see.present? ? field.can_see.call : true
          end
        when :grid
          fields = fields.select do |field|
            field.show_on_grid.present?
          end
        end

        if panel.present?
          fields = fields.select do |field|
            field.panel_name == panel
          end
        end

        # abort fields.map { |f| [f.id, f.panel_name] }.inspect

        fields = fields.map do |field|
          field.hydrate(model: @model, view: @view, resource: self)
        end

        fields
      end

      def get_field_definitions
        @field_loader.fields_bag.map do |field|
          field.hydrate(resource: self, panel_name: default_panel_name, user: user)
        end
      end

      def default_panel_name
        return @params[:related_name].capitalize if @params[:related_name].present?

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
        panels = [
          {
            name: default_panel_name,
            type: :fields,
            in_panel: true,
          }
        ]

        # return panels if @params[:via_relation_param] == 'has_one'

        # abort get_field_definitions.map(&:class).inspect

        # has_one_panels = get_field_definitions.select do |field|
        #   field.class.to_s.include? 'HasOneField'
        # end
        # .map do |field|
        #   {
        #     name: field.name,
        #     type: :has_one_relation,
        #     in_panel: false,
        #   }
        # end

        # has_many_panels = []

        # panels + has_one_panels + has_many_panels

        panels
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

      def available_view_types
        get_fields(view_type: :grid).length > 0 ? [:grid, :table] : [:table]
      end

      def get_filters
        self.class.get_filters
      end

      def get_actions
        self.class.get_actions
      end

      def route_key
        model_class.model_name.route_key
      end

      def query_search(query: '', via_resource_name: , via_resource_id:, user:)
        model_class = self.model

        db_query = AuthorizationService.apply_policy(user, model_class)

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
        fields_by_database_id = self.get_field_definitions.map { |field| [field.database_id(model).to_s, field] }.to_h

        params.each do |key, value|
          field = fields_by_database_id[key]
          puts ['field->', key, field].inspect

          next unless field

          model = field.fill_field model, key, value
        end

        model
      end

      def authorization
        AuthorizationService.new(user, model)
      end

      def file_hash
        content_to_be_hashed = ''

        # resource file hash
        resource_path = Rails.root.join('app', 'avo', 'resources', "#{name.underscore}.rb").to_s
        if File.file? resource_path
          content_to_be_hashed += File.read(resource_path)
        end

        # policy file hash
        policy_path = Rails.root.join('app', 'policies', "#{name.underscore}_policy.rb").to_s
        if File.file? policy_path
          content_to_be_hashed += File.read(policy_path)
        end

        Digest::MD5.hexdigest(content_to_be_hashed)
      end
    end
  end
end
