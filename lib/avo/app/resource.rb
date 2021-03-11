require_relative 'fields/field'

module Avo
  module Resources
    class Resource
      attr_accessor :view
      attr_accessor :model
      attr_accessor :user
      attr_accessor :fields_loader
      attr_accessor :grid_loader
      attr_accessor :actions_loader
      attr_accessor :filters_loader
      attr_accessor :params

      alias :field :fields_loader
      alias :f :field
      alias :g :grid_loader
      alias :action :actions_loader
      alias :a :action
      alias :filter :filters_loader

      class_attribute :id, default: :id
      class_attribute :title, default: :id
      class_attribute :search, default: [:id]
      class_attribute :includes, default: []
      class_attribute :translation_key
      class_attribute :default_view_type, default: :table
      class_attribute :devise_password_optional, default: false

      def initialize
        boot_fields
      end

      def boot_fields
        @fields_loader = Avo::FieldsLoader.new
        fields @fields_loader if self.respond_to? :fields

        @grid_loader = Avo::FieldsLoader.new
        grid if self.respond_to? :grid

        @actions_loader = Avo::ActionsLoader.new
        actions if self.respond_to? :actions

        @filters_loader = Avo::ActionsLoader.new
        filters if self.respond_to? :filters
      end

      def hydrate(model: nil, view: nil, user: nil, params: nil)
        @view = view if view.present?
        @user = user if user.present?
        @params = params if params.present?

        if model.present?
          @model = model

          hydrate_model_with_default_values if @view == :new
        end

        self
      end

      def get_fields(panel: nil, view_type: :table, reflection: nil)
        case view_type.to_sym
        when :table
          fields = get_field_definitions.select do |field|
            field.send("show_on_#{@view.to_s}")
          end
          .select do |field|
            field.can_see.present? ? field.can_see.call : true
          end
          .select do |field|
            unless field.respond_to?(:foreign_key) &&
              reflection.present? &&
              reflection.respond_to?(:foreign_key) &&
              reflection.foreign_key == field.foreign_key
              true
            end

          end
        when :grid
          fields = @grid_loader.bag
        end

        if panel.present?
          fields = fields.select do |field|
            field.panel_name == panel
          end
        end

        fields = fields.map do |field|
          field.hydrate(model: @model, view: @view, resource: self)
        end

        fields
      end

      def get_field_definitions
        @fields_loader.bag.map do |field|
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

        panels
      end

      def model_class
        return @model.class if @model.present?

        self.class.name.demodulize.chomp('Resource').safe_constantize
      end

      def model_title
        return @model.send title if @model.present?

        name
      end

      def name
        return @name if @name.present?

        return I18n.t(@translation_key, count: 1).capitalize if @translation_key

        self.class.name.demodulize.chomp('Resource').titlecase
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
        @filters_loader.bag
      end

      def get_actions
        @actions_loader.bag
      end

      def route_key
        model_class.model_name.route_key
      end

      def context
        App.context
      end

      def fields
        raise Error.new 'NotImplemented'
      end

      def query_search(query: '', via_resource_name: , via_resource_id:, user:)
        # model_class = self.model

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

      def cache_hash(parent_model)
        if parent_model.present?
          [self.model, self.file_hash, parent_model]
        else
          [self.model, self.file_hash]
        end
      end

      # For :new views we're hydrating the model with the values from the resource's default attribute.
      # We will not overwrite any attributes that come pre-filled in the model.
      def hydrate_model_with_default_values
        default_values = get_fields.select do |field|
          !field.computed
        end
        .map do |field|
          id = field.id
          value = field.value

          if field.respond_to? :foreign_key
            id = field.foreign_key.to_sym

            reflection = @model._reflections[@params[:via_relation]]

            if reflection.present? && reflection.foreign_key.present?
              value = @params[:via_resource_id]
            end
          end

          [id, value]
        end
        .to_h
        .select do |id, value|
          value.present?
        end

        default_values.each do |id, value|
          if @model.send(id).nil?
            @model.send("#{id}=", value)
          end
        end
      end
    end
  end
end
