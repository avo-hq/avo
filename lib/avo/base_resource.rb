module Avo
  class BaseResource
    extend ActiveSupport::DescendantsTracker

    include ActionView::Helpers::UrlHelper
    include Avo::Concerns::HasFields
    include Avo::Concerns::CanReplaceFields
    include Avo::Concerns::HasEditableControls
    include Avo::Concerns::HasStimulusControllers
    include Avo::Concerns::ModelClassConstantized

    delegate :view_context, to: ::Avo::App
    delegate :current_user, to: ::Avo::App
    delegate :params, to: ::Avo::App
    delegate :simple_format, :content_tag, to: :view_context
    delegate :main_app, to: :view_context
    delegate :avo, to: :view_context
    delegate :resource_path, to: :view_context
    delegate :resources_path, to: :view_context
    delegate :t, to: ::I18n
    delegate :context, to: ::Avo::App

    attr_accessor :view
    attr_accessor :reflection
    attr_accessor :user
    attr_accessor :params

    class_attribute :id, default: :id
    class_attribute :title, default: :id
    class_attribute :description, default: :id
    class_attribute :search_query, default: nil
    class_attribute :search_query_help, default: ""
    class_attribute :search_result_path
    class_attribute :includes, default: []
    class_attribute :authorization_policy
    class_attribute :translation_key
    class_attribute :default_view_type, default: :table
    class_attribute :devise_password_optional, default: false
    class_attribute :actions_loader
    class_attribute :filters_loader
    class_attribute :grid_loader
    class_attribute :visible_on_sidebar, default: true
    class_attribute :unscoped_queries_on_index, default: false
    class_attribute :resolve_query_scope
    class_attribute :resolve_find_scope
    # TODO: refactor this into a Host without args
    class_attribute :find_record_method, default: ->(model_class:, id:, params:) {
      model_class.find id
    }
    class_attribute :ordering
    class_attribute :hide_from_global_search, default: false
    class_attribute :after_create_path, default: :show
    class_attribute :after_update_path, default: :show
    class_attribute :record_selector, default: true
    class_attribute :keep_filters_panel_open, default: false
    class_attribute :extra_params
    class_attribute :link_to_child_resource, default: false

    class << self
      delegate :t, to: ::I18n
      delegate :context, to: ::Avo::App

      def grid(&block)
        grid_collector = GridCollector.new
        grid_collector.instance_eval(&block)

        self.grid_loader = grid_collector
      end

      def action(action_class, arguments: {})
        self.actions_loader ||= Avo::Loaders::Loader.new

        action = { class: action_class, arguments: arguments }
        self.actions_loader.use action
      end

      def filter(filter_class, arguments: {})
        self.filters_loader ||= Avo::Loaders::Loader.new

        filter = { class: filter_class , arguments: arguments }
        self.filters_loader.use filter
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
        Avo::Services::AuthorizationService.new Avo::App.current_user, model_class, policy_class: authorization_policy
      end

      def order_actions
        return {} if ordering.blank?

        ordering.dig(:actions) || {}
      end

      def get_record_associations(record)
        record._reflections
      end

      def valid_association_name(record, association_name)
        get_record_associations(record).keys.find do |name|
          name == association_name
        end
      end

      def valid_attachment_name(record, association_name)
        association_exists = get_record_associations(record).keys.any? do |name|
          name == "#{association_name}_attachment" || name == "#{association_name}_attachments"
        end
        return association_name if association_exists
      end

      def get_available_models
        ApplicationRecord.descendants
      end

      def valid_model_class(model_class)
        get_available_models.find do |m|
          m.to_s == model_class.to_s
        end
      end
    end

    def initialize
      unless self.class.model_class.present?
        if model_class.present? && model_class.respond_to?(:base_class)
          self.class.model_class = model_class.base_class
        end
      end
    end

    def record
      @model
    end
    alias :model :record

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

    def get_grid_fields
      return if self.class.grid_loader.blank?

      self.class.grid_loader.hydrate(model: @model, view: @view, resource: self)
    end

    def get_filters
      return [] if self.class.filters_loader.blank?

      self.class.filters_loader.bag
    end

    def get_filter_arguments(filter_class)
      filter = get_filters.find { |filter| filter[:class] == filter_class.constantize }

      filter[:arguments]
    end

    def get_actions
      return [] if self.class.actions_loader.blank?

      self.class.actions_loader.bag
    end

    def get_action_arguments(action_class)
      action = get_actions.find { |action| action[:class].to_s == action_class.to_s }

      action[:arguments]
    end

    def default_panel_name
      return @params[:related_name].capitalize if @params.present? && @params[:related_name].present?

      case @view
      when :show
        model_title
      when :edit
        model_title
      when :new
        t("avo.create_new_item", item: name.downcase).upcase_first
      end
    end

    def class_name_without_resource
      self.class.name.demodulize.delete_suffix("Resource")
    end

    def model_class
      # get the model class off of the static property
      return self.class.model_class if self.class.model_class.present?

      # get the model class off of the model
      return @model.base_class if @model.present?

      # generate a model class
      class_name_without_resource.safe_constantize
    end

    def model_id
      @model.send id
    end

    def model_title
      return name if @model.nil?

      the_title = @model.send title
      return the_title if the_title.present?

      model_id
    rescue
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
      return "avo.resource_translations.#{class_name_without_resource.underscore}" if ::Avo::App.translation_enabled

      self.class.translation_key
    end

    def name
      default = class_name_without_resource.to_s.gsub('::', ' ').underscore.humanize

      return @name if @name.present?

      if translation_key && ::Avo::App.translation_enabled
        t(translation_key, count: 1, default: default).capitalize
      else
        default
      end
    end

    def singular_name
      name
    end

    def plural_name
      default = name.pluralize

      if translation_key && ::Avo::App.translation_enabled
        t(translation_key, count: 2, default: default).capitalize
      else
        default
      end
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

    def attached_file_fields
      get_field_definitions.select do |field|
        [Avo::Fields::FileField, Avo::Fields::FilesField].include? field.class
      end
    end

    def fill_model(model, params, extra_params: [])
      # Map the received params to their actual fields
      fields_by_database_id = get_field_definitions
        .reject do |field|
          field.computed
        end
        .map do |field|
          [field.database_id.to_s, field]
        end
        .to_h

      # Write the field values
      params.each do |key, value|
        field = fields_by_database_id[key]

        next unless field.present?

        model = field.fill_field model, key, value, params
      end

      # Write the user configured extra params to the model
      if extra_params.present?
        # Let Rails fill in the rest of the params
        model.assign_attributes params.permit(extra_params)
      end

      model
    end

    def authorization(user: nil)
      current_user = user || Avo::App.current_user
      Avo::Services::AuthorizationService.new(current_user, model || model_class, policy_class: authorization_policy)
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
              via_resource = ::Avo::App.get_resource_by_model_name(@params[:via_relation_class])
              value = via_resource.find_record(@params[:via_resource_id])
            elsif reflection.present? && reflection.foreign_key.present? && field.id.to_s == @params[:via_relation].to_s
              resource = Avo::App.get_resource_by_model_name params[:via_relation_class]
              model = resource.find_record @params[:via_resource_id], params: params
              id_param = reflection.options[:primary_key] || :id

              value = model.send(id_param)
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
      class_name_without_resource.underscore.pluralize
    end

    def singular_route_key
      route_key.singularize
    end

    # This is used as the model class ID
    # We use this instead of the route_key to maintain compatibility with uncountable models
    # With uncountable models route key appends an _index suffix (Fish->fish_index)
    # Example: User->users, MediaItem->media_items, Fish->fish
    def model_key
      model_class.model_name.plural
    end

    def model_name
      model_class.model_name
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
      label_field&.value || model_title
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
      description_field&.value
    end

    def form_scope
      model_class.base_class.to_s.underscore.downcase
    end

    def ordering_host(**args)
      Avo::Hosts::Ordering.new resource: self, options: self.class.ordering, **args
    end

    def has_model_id?
      model.present? && model.id.present?
    end

    def find_record(id, query: nil, params: nil)
      query ||= self.class.find_scope

      self.class.find_record_method.call(model_class: query, id: id, params: params)
    end
  end
end
