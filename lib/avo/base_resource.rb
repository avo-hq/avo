module Avo
  class BaseResource
    extend ActiveSupport::DescendantsTracker
    extend FieldsCollector
    extend HasContext

    attr_accessor :view
    attr_accessor :model
    attr_accessor :user
    attr_accessor :params

    class_attribute :id, default: :id
    class_attribute :title, default: :id
    class_attribute :search_query, default: nil
    class_attribute :includes, default: []
    class_attribute :model_class
    class_attribute :translation_key
    class_attribute :default_view_type, default: :table
    class_attribute :devise_password_optional, default: false
    class_attribute :actions_loader
    class_attribute :filters_loader
    class_attribute :fields
    class_attribute :grid_loader
    class_attribute :visible_on_sidebar, default: true
    class_attribute :unscoped_queries_on_index, default: false

    class << self
      def grid(&block)
        grid_collector = GridCollector.new
        grid_collector.instance_eval(&block)

        self.grid_loader = grid_collector
      end

      def action(action_class)
        self.actions_loader ||= Avo::Loaders::Loader.new

        self.actions_loader.use action_class
      end

      def filter(filter_class)
        self.filters_loader ||= Avo::Loaders::Loader.new

        self.filters_loader.use filter_class
      end

      def scope
        authorization.apply_policy model_class
      end

      def authorization
        Avo::Services::AuthorizationService.new Avo::App.current_user
      end
    end

    def initialize
      self.class.model_class = model_class
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

    def get_field_definitions
      return [] if self.class.fields.blank?

      fields = self.class.fields.map do |field|
        field.hydrate(resource: self, panel_name: default_panel_name, user: user)
      end

      if Avo::App.license.lacks_with_trial(:custom_fields)
        fields = fields.reject do |field|
          field.custom?
        end
      end

      fields
    end

    def get_fields(panel: nil, reflection: nil)
      fields = get_field_definitions
        .select do |field|
          field.send("show_on_#{@view}")
        end
        .select do |field|
          field.visible?
        end
        .select do |field|
          # Strip out the reflection field in index queries with a parent association.
          if reflection.present? &&
              reflection.options.present? &&
              field.respond_to?(:polymorphic_as) &&
              field.polymorphic_as.to_s == reflection.options[:as].to_s
            next
          end
          if field.respond_to?(:foreign_key) &&
              reflection.present? &&
              reflection.respond_to?(:foreign_key) &&
              reflection.foreign_key != field.foreign_key
            next
          end

          true
        end

      if panel.present?
        fields = fields.select do |field|
          field.panel_name == panel
        end
      end

      hydrate_fields(model: @model, view: @view)

      fields
    end

    def get_grid_fields
      return if self.class.grid_loader.blank?

      self.class.grid_loader.hydrate(model: @model, view: @view, resource: self)
    end

    def get_filters
      return [] if self.class.filters_loader.blank?

      self.class.filters_loader.bag
    end

    def get_actions
      return [] if self.class.actions_loader.blank?

      self.class.actions_loader.bag
    end

    def hydrate_fields(model: nil, view: nil)
      fields.map do |field|
        field.hydrate(model: @model, view: @view, resource: self)
      end

      self
    end

    def default_panel_name
      return @params[:related_name].capitalize if @params.present? && @params[:related_name].present?

      case @view
      when :show
        I18n.t("avo.resource_details", item: name.downcase, title: model_title).upcase_first
      when :edit
        I18n.t("avo.update_item", item: name.downcase, title: model_title).upcase_first
      when :new
        I18n.t("avo.create_new_item", item: name.downcase).upcase_first
      end
    end

    def panels
      [
        {
          name: default_panel_name,
          type: :fields,
          in_panel: true
        }
      ]
    end

    def model_class
      return self.class.model_class if self.class.model_class.present?

      return @model.class if @model.present?

      self.class.name.demodulize.chomp("Resource").safe_constantize
    end

    def model_title
      return @model.send title if @model.present?

      name
    end

    def name
      return @name if @name.present?

      return I18n.t(@translation_key, count: 1).capitalize if @translation_key

      self.class.name.demodulize.chomp("Resource").titlecase
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
      view_types = [:table]

      view_types << :grid if get_grid_fields.present?

      view_types
    end

    def route_key
      model_class.model_name.route_key
    end

    def context
      self.class.context
    end

    def attached_file_fields
      get_field_definitions.select do |field|
        [Avo::Fields::FileField, Avo::Fields::FilesField].include? field.class
      end
    end

    def fill_model(model, params)
      # Map the received params to their actual fields
      fields_by_database_id = get_field_definitions
        .reject do |field|
          field.computed
        end
        .map do |field|
          [field.database_id(model).to_s, field]
        end
        .to_h

      params.each do |key, value|
        field = fields_by_database_id[key]

        next unless field.present?

        model = field.fill_field model, key, value, params
      end

      model
    end

    def authorization
      Avo::Services::AuthorizationService.new(user, model)
    end

    def file_hash
      content_to_be_hashed = ""

      # resource file hash
      resource_path = Rails.root.join("app", "avo", "resources", "#{self.class.name.underscore}.rb").to_s
      if File.file? resource_path
        content_to_be_hashed += File.read(resource_path)
      end

      # policy file hash
      policy_path = Rails.root.join("app", "policies", "#{self.class.name.underscore.gsub("_resource", "")}_policy.rb").to_s
      if File.file? policy_path
        content_to_be_hashed += File.read(policy_path)
      end

      Digest::MD5.hexdigest(content_to_be_hashed)
    end

    def cache_hash(parent_model)
      if parent_model.present?
        [model, file_hash, parent_model]
      else
        [model, file_hash]
      end
    end

    # We will not overwrite any attributes that come pre-filled in the model.
    def hydrate_model_with_default_values
      default_values = get_fields
        .select do |field|
          !field.computed
        end
        .map do |field|
          id = field.id
          value = field.value

          if field.type == "belongs_to"
            id = field.foreign_key.to_sym

            reflection = @model._reflections[@params[:via_relation]]

            if field.polymorphic_as.present? && field.types.map(&:to_s).include?(@params["via_relation_class"])
              value = @params["via_relation_class"].safe_constantize.find(@params[:via_resource_id])
            elsif reflection.present? && reflection.foreign_key.present? && field.id.to_s == @params[:via_relation].to_s
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

    def avo_path
      "#{Avo::App.root_path}/resources/#{model_class.model_name.route_key}/#{model.id}"
    end

    def label_field
      get_field_definitions.find do |field|
        field.as_label.present?
      end
    rescue
      nil
    end

    def label
      label_field.value || model_title
    rescue
      model_title
    end

    def avatar_field
      get_field_definitions.find do |field|
        field.as_avatar.present?
      end
    rescue
      nil
    end

    def avatar
      return avatar_field.to_image if avatar_field.respond_to? :to_image

      avatar_field.value
    rescue
      nil
    end

    def avatar_type
      avatar_field.as_avatar
    rescue
      nil
    end

    def description_field
      get_field_definitions.find do |field|
        field.as_description.present?
      end
    rescue
      nil
    end

    def description
      description_field.value
    rescue
      nil
    end
  end
end
