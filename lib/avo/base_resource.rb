module Avo
  class BaseResource
    extend ActiveSupport::DescendantsTracker
    extend FieldsCollector
    extend HasContext

    include ActionView::Helpers::UrlHelper

    delegate :view_context, to: "Avo::App"
    delegate :main_app, to: :view_context
    delegate :avo, to: :view_context
    delegate :resource_path, to: :view_context
    delegate :resources_path, to: :view_context

    attr_accessor :view
    attr_accessor :model
    attr_accessor :reflection
    attr_accessor :user
    attr_accessor :params

    class_attribute :id, default: :id
    class_attribute :title, default: :id
    class_attribute :description, default: :id
    class_attribute :search_query, default: nil
    class_attribute :search_query_help, default: ""
    class_attribute :includes, default: []
    class_attribute :model_class
    class_attribute :translation_key
    class_attribute :translation_enabled
    class_attribute :default_view_type, default: :table
    class_attribute :devise_password_optional, default: false
    class_attribute :actions_loader
    class_attribute :filters_loader
    class_attribute :fields
    class_attribute :grid_loader
    class_attribute :visible_on_sidebar, default: true
    class_attribute :unscoped_queries_on_index, default: false
    class_attribute :resolve_query_scope
    class_attribute :resolve_find_scope
    class_attribute :ordering

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

      # This is the search_query scope
      # This should be removed and passed to the search block
      def scope
        query_scope
      end

      # This resolves the scope when doing "where" queries (not find queries)
      def query_scope
        final_scope = resolve_query_scope.present? ? resolve_query_scope.call(model_class: model_class) : model_class

        authorization.apply_policy final_scope
      end

      # This resolves the scope when finding records (not "where" queries)
      def find_scope
        final_scope = resolve_find_scope.present? ? resolve_find_scope.call(model_class: model_class) : model_class

        authorization.apply_policy final_scope
      end

      def authorization
        Avo::Services::AuthorizationService.new Avo::App.current_user
      end

      def order_actions
        return {} if ordering.blank?

        ordering.dig(:actions) || {}
      end
    end

    def initialize
      unless self.class.model_class.present?
        self.class.model_class = model_class.base_class
      end
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
        field.hydrate(resource: self, panel_name: default_panel_name, user: user, translation_enabled: translation_enabled)
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
          is_valid = true

          # Strip out the reflection field in index queries with a parent association.
          if reflection.present?
            # regular non-polymorphic association
            # we're matching the reflection inverse_of foriegn key with the field's foreign_key
            if field.is_a?(Avo::Fields::BelongsToField)
              if field.respond_to?(:foreign_key) &&
                  reflection.inverse_of.present? &&
                  reflection.inverse_of.foreign_key == field.foreign_key
                is_valid = false
              end

              # polymorphic association
              if field.respond_to?(:foreign_key) &&
                  field.is_polymorphic? &&
                  reflection.respond_to?(:polymorphic?) &&
                  reflection.inverse_of.foreign_key == field.reflection.foreign_key
                is_valid = false
              end
            end
          end

          is_valid
        end

      if panel.present?
        fields = fields.select do |field|
          field.panel_name == panel
        end
      end

      hydrate_fields(model: @model, view: @view)

      fields
    end

    def get_field(id)
      get_field_definitions.find do |f|
        f.id == id.to_sym
      end
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

    def class_name_without_resource
      self.class.name.demodulize.chomp("Resource")
    end

    def model_class
      # get the model class off of the static property
      return self.class.model_class if self.class.model_class.present?

      # get the model class off of the model
      return @model.base_class if @model.present?

      # generate a model class
      class_name_without_resource.safe_constantize
    end

    def model_title
      return @model.send title if @model.present?

      name
    end

    def resource_description
      return instance_exec(&self.class.description) if self.class.description.respond_to? :call

      # Show the description only on the resource index view.
      # If the user wants to conditionally it on all pages, they should use a block.
      if view == :index
        return self.class.description if self.class.description.is_a? String
      end
    end

    def translation_key
      return "avo.resource_translations.#{class_name_without_resource.underscore}" if self.class.translation_enabled

      self.class.translation_key
    end

    def name
      return @name if @name.present?

      return I18n.t(translation_key, count: 1).capitalize if translation_key

      class_name_without_resource.titlecase
    end

    def singular_name
      name
    end

    def plural_name
      return I18n.t(translation_key, count: 2).capitalize if translation_key

      name.pluralize
    end

    def underscore_name
      return @name if @name.present?

      self.class.name.demodulize.underscore
    end

    def navigation_label
      plural_name.humanize
    end

    def available_view_types
      view_types = [:table]

      view_types << :grid if get_grid_fields.present?

      view_types
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
      Avo::Services::AuthorizationService.new(user, model || model_class)
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

            if field.polymorphic_as.present? && field.types.map(&:to_s).include?(@params[:via_relation_class])
              # set the value to the actual record
              value = @params[:via_relation_class].safe_constantize.find(@params[:via_resource_id])
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

    def route_key
      model_class.model_name.route_key
    end

    # This is used as the model class ID
    # We use this instead of the route_key to maintain compatibility with uncountable models
    # With uncountable models route key appends an _index suffix (Fish->fish_index)
    # Example: User->users, MediaItem->medie_items, Fish->fish
    def model_key
      model_class.model_name.plural
    end

    def singular_model_key
      model_class.model_name.singular
    end

    def record_path
      resource_path(model: model, resource: self)
    end

    def records_path
      resources_path(resource: self)
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

      return avatar_field.value.variant(resize_to_limit: [480, 480]) if avatar_field.type == "file"

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

    def form_scope
      model_class.base_class.to_s.underscore.downcase
    end

    def ordering_host(**args)
      Avo::Hosts::Ordering.new resource: self, options: self.class.ordering, **args
    end
  end
end
