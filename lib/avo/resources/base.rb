module Avo
  module Resources
    class Base
      extend ActiveSupport::DescendantsTracker

      include ActionView::Helpers::UrlHelper
      include Avo::Concerns::HasItems
      include Avo::Concerns::CanReplaceItems
      include Avo::Concerns::HasControls
      include Avo::Concerns::HasResourceStimulusControllers
      include Avo::Concerns::ModelClassConstantized
      include Avo::Concerns::HasDescription
      include Avo::Concerns::HasCoverPhoto
      include Avo::Concerns::HasProfilePhoto
      include Avo::Concerns::HasHelpers
      include Avo::Concerns::Hydration
      include Avo::Concerns::Pagination
      include Avo::Concerns::ControlsPlacement

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
      class_attribute :attachments, default: []
      class_attribute :single_includes, default: []
      class_attribute :single_attachments, default: []
      class_attribute :authorization_policy
      class_attribute :translation_key
      class_attribute :default_view_type, default: :table
      class_attribute :devise_password_optional, default: false
      class_attribute :scopes_loader
      class_attribute :filters_loader
      class_attribute :view_types
      class_attribute :grid_view
      class_attribute :confirm_on_save, default: false
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
      class_attribute :default_sort_column, default: :created_at
      class_attribute :default_sort_direction, default: :desc
      class_attribute :controls_placement, default: nil

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

        def valid_association_name(record, association_name)
          association_name if record.class.reflect_on_association(association_name).present?
        end

        def valid_attachment_name(record, association_name)
          association_name if record.class.reflect_on_attachment(association_name).present?
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
          return constantized_model_class if @model_class.present?

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
          @model_key ||= model_class.model_name.plural
        end

        def class_name
          @class_name ||= to_s.demodulize
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
          @name ||= name_from_translation_key(count: 1, default: class_name.underscore.humanize)
        end
        alias_method :singular_name, :name

        def plural_name
          name_from_translation_key(count: 2, default: name.pluralize)
        end

        # Get the name from the translation_key and fallback to default
        # It can raise I18n::InvalidPluralizationData when using only resource_translation without pluralization keys like: one, two or other key
        # Example:
        # ---
        # en:
        #   avo:
        #     resource_translations:
        #       product:
        #         save: "Save product"
        def name_from_translation_key(count:, default:)
          t(translation_key, count:, default:).humanize
        rescue I18n::InvalidPluralizationData
          default
        end

        def underscore_name
          return @name if @name.present?

          name.demodulize.underscore
        end

        def navigation_label
          plural_name.humanize
        end

        def find_record(id, query: nil, params: nil)
          query ||= find_scope # If no record is given we'll use the default

          if single_includes.present?
            query = query.includes(*single_includes)
          end

          if single_attachments.present?
            single_attachments.each do |attachment|
              query = query.send(:"with_attached_#{attachment}")
            end
          end

          Avo::ExecutionContext.new(
            target: find_record_method,
            query: query,
            id: id,
            params: params
          ).handle
        end

        def search_query
          search.dig(:query)
        end

        def search_results_count
          search.dig(:results_count)
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
      delegate :to_param, to: :class
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

      unless defined? VIEW_METHODS_MAPPING
        VIEW_METHODS_MAPPING = {
          index: [:index_fields, :display_fields],
          show: [:show_fields, :display_fields],
          edit: [:edit_fields, :form_fields],
          update: [:edit_fields, :form_fields],
          new: [:new_fields, :form_fields],
          create: [:new_fields, :form_fields]
        }
      end

      def fetch_fields
        if view.preview?
          [:fields, :index_fields, :show_fields, :display_fields].each do |fields_method|
            send(fields_method) if respond_to?(fields_method)
          end

          return
        end

        possible_methods_for_view = VIEW_METHODS_MAPPING[view.to_sym]

        # Safe navigation operator is used because the view can be "destroy"
        possible_methods_for_view&.each do |method_for_view|
          return send(method_for_view) if respond_to?(method_for_view)
        end

        fields
      end

      def fetch_cards
        cards
      end

      def divider(**kwargs)
        entity_loader(:action).use({class: Divider, **kwargs}.compact)
      end

      # def fields / def cards
      [:fields, :cards].each do |method_name|
        define_method method_name do
          # Empty method
        end
      end

      [:action, :filter, :scope].each do |entity|
        plural_entity = entity.to_s.pluralize

        # def actions / def filters / def scopes
        define_method plural_entity do
          # blank entity method
        end

        # def action / def filter / def scope
        define_method entity do |entity_class, arguments: {}, icon: nil, default: nil|
          entity_loader(entity).use({class: entity_class, arguments: arguments, icon: icon, default: default}.compact)
        end

        # def get_actions / def get_filters / def get_scopes
        define_method :"get_#{plural_entity}" do
          return entity_loader(entity).bag if entity_loader(entity).present?

          # ex: @actions_loader = Avo::Loaders::ActionsLoader.new
          instance_variable_set(
            :"@#{plural_entity}_loader",
            "Avo::Loaders::#{plural_entity.humanize}Loader".constantize.new
          )

          send plural_entity

          entity_loader(entity).bag
        end

        # def get_action_arguments / def get_filter_arguments / def get_scope_arguments
        define_method :"get_#{entity}_arguments" do |entity_class|
          klass = send(:"get_#{plural_entity}").find { |entity| entity[:class].to_s == entity_class.to_s }

          raise "Couldn't find '#{entity_class}' in the 'def #{plural_entity}' method on your '#{self.class}' resource." if klass.nil?

          klass[:arguments]
        end
      end

      def hydrate(...)
        super

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
        fetch_record_title.to_s
      end

      def fetch_record_title
        return name if @record.nil?

        # Get the title from the record if title is not set, try to get the name, title or label, or fallback to the to_param
        return @record.try(:name) || @record.try(:title) || @record.try(:label) || @record.to_param if title.nil?

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

      def fill_record(record, permitted_params, extra_params: [], fields: nil)
        # Write the field values
        permitted_params.each do |key, value|
          field = if fields.present?
            fields.find { |f| f.id == key.to_sym }
          else
            fields_by_database_id[key]
          end

          next unless field.present?

          record = field.fill_field record, key, value, permitted_params
        end

        # Write the user configured extra params to the record
        if extra_params.present?
          # Pick only the extra params
          # params at this point are already permited, only need the keys to access them
          extra_attributes = permitted_params.slice(*flatten_keys(extra_params))

          # Let Rails fill in the rest of the params
          record.assign_attributes extra_attributes
        end

        record
      end

      def authorization(user: nil)
        current_user = user || Avo::Current.user
        Avo::Services::AuthorizationService.new(current_user, record || model_class, policy_class: authorization_policy)
      end

      def file_hash
        content_to_be_hashed = ""

        resource_path = Rails.root.join("app", "avo", "resources", "#{file_name}.rb").to_s
        if File.file? resource_path
          content_to_be_hashed += File.read(resource_path)
        end

        # policy file hash
        policy_path = Rails.root.join("app", "policies", "#{file_name.gsub("_resource", "")}_policy.rb").to_s
        if File.file? policy_path
          content_to_be_hashed += File.read(policy_path)
        end

        Digest::MD5.hexdigest(content_to_be_hashed)
      end

      def file_name
        @file_name ||= self.class.underscore_name.tr(" ", "_")
      end

      def cache_hash(parent_record)
        result = [record, file_hash]

        if parent_record.present?
          result << parent_record
        end

        result
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

              reflection = @record.class.reflect_on_association(@params[:via_relation]) if @params[:via_relation].present?

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

      def entity_loader(entity)
        instance_variable_get(:"@#{entity.to_s.pluralize}_loader")
      end

      def record_param
        @record_param ||= @record.persisted? ? @record.to_param : nil
      end

      def custom_components
        @custom_components ||= Avo::ExecutionContext.new(
          target: components,
          resource: self,
          record: @record,
          view: @view
        ).handle.with_indifferent_access
      end

      def resolve_component(original_component)
        custom_components.dig(original_component.to_s)&.to_s&.safe_constantize || original_component
      end

      private

      def flatten_keys(array)
        # [:fish_type, information: [:name, :history], reviews_attributes: [:body, :user_id]]
        # becomes
        # [:fish_type, :information, :reviews_attributes]
        array.flat_map do |item|
          case item
          when Hash
            item.keys
          else
            item
          end
        end
      end
    end
  end
end
