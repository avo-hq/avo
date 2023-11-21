module Avo
  class BaseResource
    extend ActiveSupport::DescendantsTracker

    include ActionView::Helpers::UrlHelper
    include Avo::Concerns::HasItems
    include Avo::Concerns::CanReplaceItems
    include Avo::Concerns::HasControls
    include Avo::Concerns::HasStimulusControllers
    include Avo::Concerns::ModelClassConstantized
    include Avo::Concerns::HasDescription
    include Avo::Concerns::HasHelpers
    include Avo::Concerns::Hydration
    include Avo::Concerns::Pagination

    # Avo::Current methods
    delegate :context, to: Avo::Current
    def current_user
      Avo::Current.user
    end
    delegate :params, to: Avo::Current
    delegate :request, to: Avo::Current
    delegate :view_context, to: Avo::Current

    # view_context methods
    delegate :simple_format, :content_tag, to: :view_context
    delegate :main_app, to: :view_context
    delegate :avo, to: :view_context
    delegate :resource_path, to: :view_context
    delegate :resources_path, to: :view_context

    # I18n methods
    delegate :t, to: ::I18n

    # class methods
    delegate :class_name, to: :class
    delegate :route_key, to: :class
    delegate :singular_route_key, to: :class

    attr_accessor :view
    attr_accessor :reflection
    attr_accessor :user
    attr_accessor :record

    class_attribute :id, default: :id
    class_attribute :title
    class_attribute :search, default: {}
    class_attribute :includes, default: []
    class_attribute :authorization_policy
    class_attribute :translation_key
    class_attribute :default_view_type, default: :table
    class_attribute :devise_password_optional, default: false
    class_attribute :scopes_loader
    class_attribute :filters_loader
    class_attribute :view_types
    class_attribute :grid_view
    class_attribute :visible_on_sidebar, default: true
    class_attribute :index_query, default: -> {
      query
    }
    class_attribute :find_record_method, default: -> {
      query.find id
    }
    class_attribute :after_create_path, default: :show
    class_attribute :after_update_path, default: :show
    class_attribute :record_selector, default: true
    class_attribute :keep_filters_panel_open, default: false
    class_attribute :extra_params
    class_attribute :link_to_child_resource, default: false
    class_attribute :map_view
    class_attribute :components, default: {}

    # EXTRACT:
    class_attribute :ordering

    class << self
      delegate :t, to: ::I18n
      delegate :context, to: ::Avo::Current

      def action(action_class, arguments: {})
        deprecated_dsl_api __method__, "actions"
      end

      def filter(filter_class, arguments: {})
        deprecated_dsl_api __method__, "filters"
      end

      def scope(scope_class)
        deprecated_dsl_api __method__, "scopes"
      end

      # This resolves the scope when doing "where" queries (not find queries)
      #
      # It's used to apply the authorization feature.
      def query_scope
        authorization.apply_policy Avo::ExecutionContext.new(
          target: index_query,
          query: model_class
        ).handle
      end

      # This resolves the scope when finding records (not "where" queries)
      #
      # It's used to apply the authorization feature.
      def find_scope
        authorization.apply_policy model_class
      end

      def authorization
        Avo::Services::AuthorizationService.new Avo::Current.user, model_class, policy_class: authorization_policy
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

      def get_model_by_name(model_name)
        get_available_models.find do |m|
          m.to_s == model_name.to_s
        end
      end

      # Returns the model class being used for this resource.
      #
      # The Resource instance has a model_class method too so it can support the STI use cases
      # where we figure out the model class from the record
      def model_class(record_class: nil)
        # get the model class off of the static property
        return @model_class if @model_class.present?

        # get the model class off of the record for STI models
        return record_class if record_class.present?

        # generate a model class
        class_name.safe_constantize
      end

      # This is used as the model class ID
      # We use this instead of the route_key to maintain compatibility with uncountable models
      # With uncountable models route key appends an _index suffix (Fish->fish_index)
      # Example: User->users, MediaItem->media_items, Fish->fish
      def model_key
        model_class.model_name.plural
      end

      def class_name
        to_s.demodulize
      end

      def route_key
        class_name.underscore.pluralize
      end

      def singular_route_key
        route_key.singularize
      end

      def translation_key
        @translation_key || "avo.resource_translations.#{class_name.underscore}"
      end

      def name
        default = class_name.underscore.humanize

        if translation_key
          t(translation_key, count: 1, default: default).humanize
        else
          default
        end
      end
      alias_method :singular_name, :name

      def plural_name
        default = name.pluralize

        if translation_key
          t(translation_key, count: 2, default: default).humanize
        else
          default
        end
      end

      def underscore_name
        return @name if @name.present?

        name.demodulize.underscore
      end

      def navigation_label
        plural_name.humanize
      end

      def find_record(id, query: nil, params: nil)
        Avo::ExecutionContext.new(
          target: find_record_method,
          query: query || find_scope, # If no record is given we'll use the default
          id: id,
          params: params
        ).handle
      end

      def search_query
        search.dig(:query)
      end

      def fetch_search(key, record: nil)
        # self.class.fetch_search
        Avo::ExecutionContext.new(target: search[key], resource: self, record: record).handle
      end
    end

    delegate :context, to: ::Avo::Current
    delegate :name, to: :class
    delegate :singular_name, to: :class
    delegate :plural_name, to: :class
    delegate :underscore_name, to: :class
    delegate :underscore_name, to: :class
    delegate :find_record, to: :class
    delegate :model_key, to: :class
    delegate :tab, to: :items_holder

    def initialize(record: nil, view: nil, user: nil, params: nil)
      @view = Avo::ViewInquirer.new(view) if view.present?
      @user = user if user.present?
      @params = params if params.present?

      if record.present?
        @record = record

        hydrate_model_with_default_values if @view&.new?
      end

      unless self.class.model_class.present?
        if model_class.present? && model_class.respond_to?(:base_class)
          self.class.model_class = model_class.base_class
        end
      end
    end

    def detect_fields
      self.items_holder = Avo::Resources::Items::Holder.new(parent: self)

      # Used in testing to replace items
      if temporary_items.present?
        instance_eval(&temporary_items)
      else
        fetch_fields
      end

      self
    end

    VIEW_METHODS_MAPPING = {
      index: [:index_fields, :display_fields],
      show: [:show_fields, :display_fields],
      edit: [:edit_fields, :form_fields],
      update: [:edit_fields, :form_fields],
      new: [:new_fields, :form_fields],
      create: [:new_fields, :form_fields]
    } unless defined? VIEW_METHODS_MAPPING

    def fetch_fields
      possible_methods_for_view = VIEW_METHODS_MAPPING[view.to_sym]

      # Safe navigation operator is used because the view can be "destroy" or "preview"
      possible_methods_for_view&.each do |method_for_view|
        return send(method_for_view) if respond_to?(method_for_view)
      end

      fields
    end

    def fields
      # blank fields method
    end

    [:action, :filter, :scope].each do |entity|
      plural_entity = entity.to_s.pluralize

      # def actions / def filters / def scopes
      define_method plural_entity do
        # blank entity method
      end

      # def action / def filter / def scope
      define_method entity do |entity_class, arguments: {}|
        entity_loader(entity).use({class: entity_class, arguments: arguments})
      end

      # def get_actions / def get_filters / def get_scopes
      define_method "get_#{plural_entity}" do
        return entity_loader(entity).bag if entity_loader(entity).present?

        instance_variable_set("@#{plural_entity}_loader", Avo::Loaders::Loader.new)
        send plural_entity

        entity_loader(entity).bag
      end

      # def get_action_arguments / def get_filter_arguments / def get_scope_arguments
      define_method "get_#{entity}_arguments" do |entity_class|
        klass = send("get_#{plural_entity}").find { |entity| entity[:class].to_s == entity_class.to_s }

        raise "Couldn't find '#{entity_class}' in the 'def #{plural_entity}' method on your '#{self.class}' resource." if klass.nil?

        klass[:arguments]
      end
    end

    def hydrate(...)
      super(...)

      if @record.present?
        hydrate_model_with_default_values if @view&.new?
      end

      self
    end

    def default_panel_name
      return @params[:related_name].capitalize if @params.present? && @params[:related_name].present?

      case @view.to_sym
      when :show
        record_title
      when :edit
        record_title
      when :new
        t("avo.create_new_item", item: name.humanize(capitalize: false)).upcase_first
      end
    end

    # Returns the model class being used for this resource.
    #
    # We use the class method as a fallback but we pass it the record too so it can support the STI use cases
    # where we figure out the model class from that record.
    def model_class
      record_class = @record&.class

      self.class.model_class record_class: record_class
    end

    def record_title
      return name if @record.nil?

      # Get the title from the record if title is not set, try to get the name, title or label, or fallback to the id
      return @record.try(:name) || @record.try(:title) || @record.try(:label) || @record.id  if title.nil?

      # If the title is a symbol, get the value from the record else execute the block/string
      case title
      when Symbol
        @record.send title
      when Proc
        Avo::ExecutionContext.new(target: title, resource: self, record: @record).handle
      end
    end

    def available_view_types
      if self.class.view_types.present?
        return Array(
          Avo::ExecutionContext.new(
            target: self.class.view_types,
            resource: self,
            record: record
          ).handle
        )
      end

      view_types = [:table]

      view_types << :grid if self.class.grid_view.present?
      view_types << :map if map_view.present?

      view_types
    end

    def attachment_fields
      get_field_definitions.select do |field|
        [Avo::Fields::FileField, Avo::Fields::FilesField].include? field.class
      end
    end

    # Map the received params to their actual fields
    def fields_by_database_id
      get_field_definitions
        .reject do |field|
          field.computed
        end
        .map do |field|
          [field.database_id.to_s, field]
        end
        .to_h
    end

    def fill_record(record, params, extra_params: [])
      # Write the field values
      params.each do |key, value|
        field = fields_by_database_id[key]

        next unless field.present?

        record = field.fill_field record, key, value, params
      end

      # Write the user configured extra params to the record
      if extra_params.present?
        # Let Rails fill in the rest of the params
        record.assign_attributes params.permit(extra_params)
      end

      record
    end

    def authorization(user: nil)
      current_user = user || Avo::Current.user
      Avo::Services::AuthorizationService.new(current_user, record || model_class, policy_class: authorization_policy)
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

    def cache_hash(parent_record)
      if parent_record.present?
        [record, file_hash, parent_record]
      else
        [record, file_hash]
      end
    end

    # We will not overwrite any attributes that come pre-filled in the record.
    def hydrate_model_with_default_values
      default_values = get_fields
        .select do |field|
          !field.computed && !field.is_a?(Avo::Fields::HeadingField)
        end
        .map do |field|
          value = field.value

          if field.type == "belongs_to"

            reflection = @record._reflections[@params[:via_relation]]

            if field.polymorphic_as.present? && field.types.map(&:to_s).include?(@params[:via_relation_class])
              # set the value to the actual record
              via_resource = Avo.resource_manager.get_resource_by_model_class(@params[:via_relation_class])
              value = via_resource.find_record(@params[:via_record_id])
            elsif reflection.present? && reflection.foreign_key.present? && field.id.to_s == @params[:via_relation].to_s
              resource = Avo.resource_manager.get_resource_by_model_class params[:via_relation_class]
              record = resource.find_record @params[:via_record_id], params: params
              id_param = reflection.options[:primary_key] || :id

              value = record.send(id_param)
            end
          end

          [field, value]
        end
        .to_h
        .select do |_, value|
          value.present?
        end

      default_values.each do |field, value|
        field.assign_value record: @record, value: value
      end
    end

    def model_name
      model_class.model_name
    end

    def singular_model_key
      model_class.model_name.singular
    end

    def record_path
      resource_path(record: record, resource: self)
    end

    def records_path
      resources_path(resource: self)
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

    def form_scope
      model_class.base_class.to_s.underscore.downcase
    end

    def has_record_id?
      record.present? && record_id.present?
    end

    def id_attribute
      :id
    end

    def record_id
      record.send(id_attribute)
    end

    def description_attributes
      {
        view: view,
        resource: self,
        record: record
      }
    end

    private

    def entity_loader(entity)
      instance_variable_get("@#{entity.to_s.pluralize}_loader")
    end
  end
end
