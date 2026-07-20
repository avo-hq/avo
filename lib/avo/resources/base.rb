module Avo
  module Resources
    class Base
      extend ActiveSupport::DescendantsTracker

      include ActionView::Helpers::UrlHelper
      include Avo::Concerns::HasFieldDiscovery
      include Avo::Concerns::HasItems
      include Avo::Concerns::CanReplaceItems
      include Avo::Concerns::HasControls
      include Avo::Concerns::HasResourceStimulusControllers
      include Avo::Concerns::ModelClassConstantized
      include Avo::Concerns::HasDescription
      include Avo::Concerns::HasCover
      include Avo::Concerns::HasAvatar
      include Avo::Concerns::HasHelpers
      include Avo::Concerns::Hydration
      include Avo::Concerns::Pagination
      include Avo::Concerns::HasDiscreetInformation
      include Avo::Concerns::RowControlsConfiguration
      include Avo::Concerns::SafeCall
      include Avo::Concerns::AbstractResource

      abstract_resource!

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

      # === Dynamic-config option registry (Unit 2) ===
      #
      # Plain `class_attribute` leaves nothing queryable, so the overlay's
      # completeness check (R8) would have nothing to introspect. We intercept
      # `class_attribute` and record every option name declared directly on a
      # class into a per-class list. `Avo::Resources::Base.own_dynamic_config_option_attributes`
      # is then the source of truth the completeness spec compares against the
      # classified/excluded lists, so adding a new option in core fails CI until
      # it is classified.
      #
      # Only declarations *lexically below this point* are recorded — the option
      # class_attributes on Base itself. The concern-contributed class_attributes
      # (included above) are out of Unit 2's scope; Unit 6 extends coverage.
      def self.class_attribute(*names, **options)
        (@own_dynamic_config_option_attributes ||= []).concat(names.map(&:to_sym))
        super
      end

      def self.own_dynamic_config_option_attributes
        (@own_dynamic_config_option_attributes ||= []).uniq
      end

      unless defined?(DYNAMIC_CONFIG_OPTIONS)
        # Resource options the overlay may override (R7/R8). Exposed to Unit 6 via
        # `dynamic_config_options`. Classifications are directional here; Unit 6
        # owns the final per-option metadata.
        DYNAMIC_CONFIG_OPTIONS = %i[
          title
          icon
          search
          includes
          attachments
          single_includes
          single_attachments
          custom_translation_key
          default_view_type
          devise_password_optional
          view_types
          grid_view
          table_view
          confirm_on_save
          visible_on_sidebar
          hotkey
          index_query
          find_record_method
          after_create_path
          after_update_path
          record_selector
          keep_filters_panel_open
          extra_params
          link_to_child_resource
          map_view
          components
          default_sort_column
          default_sort_direction
          external_link
        ].freeze

        # Options declared as class_attributes but NOT overridable via the overlay
        # in v1: identity/routing (`id`), the locked policy class (R28), internal
        # loaders, and abstract/ordering machinery.
        DYNAMIC_CONFIG_EXCLUDED_OPTIONS = %i[
          id
          authorization_policy
          scopes_loader
          filters_loader
          abstract
          ordering
        ].freeze
      end

      # The overridable resource option names (consumed by Unit 6's metadata
      # registry and its re-validation against core's enumeration).
      def self.dynamic_config_options
        DYNAMIC_CONFIG_OPTIONS
      end

      # === Lock DSL (R28) ===
      #
      # `self.locked_options :some_option` marks options the overlay can never
      # override on this resource (on top of the core default-locked set). Locks
      # are enforced core-side in every seam, so they hold against a buggy or
      # hostile provider.
      def self.locked_options(*names)
        @locked_options ||= []
        @locked_options.concat(names.flatten.map(&:to_sym)) if names.any?
        @locked_options
      end

      # True when an option is locked against overlay overrides — either the core
      # default-locked set or a `locked_options` declaration anywhere up the
      # ancestry chain.
      def self.dynamic_config_locked_option?(option)
        option = option.to_sym
        return true if Avo::DynamicConfigProvider.default_locked_resource_option?(option)

        klass = self
        while klass.respond_to?(:locked_options)
          declared = klass.instance_variable_get(:@locked_options)
          return true if declared&.include?(option)
          klass = klass.superclass
        end

        false
      end

      # Read a resource option through the overlay for a *class-level* consumer
      # (query_scope, find_record, search, navigation). Locked options and the
      # no-provider path return the file value with a single predicate check.
      def self.dynamic_config_option(option, file_value)
        return file_value if dynamic_config_locked_option?(option)

        Avo.apply_dynamic_config(file_value) do |provider|
          overrides = provider.entity_options_for(self)
          (overrides.is_a?(Hash) && overrides.key?(option.to_sym)) ? overrides[option.to_sym] : file_value
        end
      end

      def dynamic_config_locked_option?(option)
        self.class.dynamic_config_locked_option?(option)
      end

      class_attribute :id, default: :id
      class_attribute :title # TODO: extract this to HasTitle concern
      class_attribute :icon
      class_attribute :search, default: {}
      class_attribute :includes, default: []
      class_attribute :attachments, default: []
      class_attribute :single_includes, default: []
      class_attribute :single_attachments, default: []
      class_attribute :authorization_policy
      class_attribute :custom_translation_key
      class_attribute :default_view_type, default: :table
      class_attribute :devise_password_optional, default: false
      class_attribute :scopes_loader
      class_attribute :filters_loader
      class_attribute :view_types
      class_attribute :grid_view
      class_attribute :table_view
      class_attribute :confirm_on_save, default: false
      class_attribute :visible_on_sidebar, default: true
      class_attribute :hotkey, default: nil
      class_attribute :index_query, default: -> {
        query
      }
      class_attribute :find_record_method, default: -> {
        # Check if the model uses FriendlyId and handle accordingly
        # If scope is configured, use the default find behavior
        if model_class.respond_to?(:friendly_id_config) && !model_class.friendly_id_config.respond_to?(:scope)
          if id.is_a?(Array)
            # For arrays, use the slug column
            query.where(model_class.friendly_id_config.slug_column => id)
          else
            # For single values, use find_by_slug method
            query.friendly.find(id)
          end
        else
          # Standard Rails find behavior for non-FriendlyId models
          query.find id
        end
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
      class_attribute :external_link, default: nil

      class_attribute :abstract, default: false

      # EXTRACT:
      class_attribute :ordering

      class << self
        delegate :t, to: ::I18n
        delegate :context, to: ::Avo::Current

        # This resolves the scope when doing "where" queries (not find queries)
        #
        # It's used to apply the authorization feature.
        def query_scope
          authorization.apply_policy Avo::ExecutionContext.new(
            target: dynamic_config_option(:index_query, index_query),
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
          @class_name ||= to_s.delete_prefix("Avo::Resources::")
        end

        # Last segment only — used for display, translation keys, and initials
        def demodulized_class_name
          class_name.demodulize
        end

        # Slash-separated URL slug: "accounts/invoices", "users"
        def route_path
          parts = class_name.split("::")
          parts.map!(&:underscore)
          parts[-1] = parts[-1].pluralize
          parts.join("/")
        end

        # Underscore-joined Rails resource identifier: "accounts_invoices", "users"
        def route_key
          route_path.tr("/", "_")
        end

        def singular_route_key
          route_key.singularize
        end

        # Same as route_path — resolves to the correct namespaced controller inside isolate_namespace
        def controller_path
          route_path
        end

        def translation_key
          custom_translation_key || "avo.resource_translations.#{class_name.underscore}"
        end
        alias_method :translation_key=, :custom_translation_key=

        def name
          name_from_translation_key(count: 1, default: demodulized_class_name.underscore.humanize)
        end
        alias_method :singular_name, :name

        def initials
          name.to_s.split(" ").map(&:first).join("").first(2).upcase
        end

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
          name.demodulize.underscore
        end

        def navigation_label
          dynamic_config_option(:navigation_label, plural_name.humanize)
        end

        # Class-level re-icon seam for the sidebar/navigation, mirroring
        # `navigation_label`. Reads the file `icon` (a plain class_attribute)
        # through the overlay. It is a *separate* method rather than a wrapper of
        # the `icon` reader on purpose: on ActiveSupport < 8.0, `self.icon = ...`
        # in a subclass redefines that subclass's `icon` reader method, which would
        # silently shadow any override placed on the reader itself. Navigation
        # consumers call `navigation_icon`; the instance `icon` reader (used for
        # record icons) is untouched and gets its override via the instance seam.
        def navigation_icon
          dynamic_config_option(:icon, icon)
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
            target: dynamic_config_option(:find_record_method, find_record_method),
            query: query,
            id: id,
            params: params,
            model_class:
          ).handle
        end

        def search_query
          dynamic_config_option(:search, search).dig(:query)
        end

        def fetch_search(key, record: nil)
          # self.class.fetch_search
          search_config = dynamic_config_option(:search, search)
          Avo::ExecutionContext.new(target: search_config[key], resource: self, record: record).handle
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
      delegate :translation_key, to: :class
      delegate :tab, to: :items_holder

      def initialize(record: nil, view: nil, user: nil, params: nil)
        @view = Avo::ViewInquirer.new(view) if view.present?
        @user = user if user.present?
        @params = params.presence || {}

        if record.present?
          @record = record

          hydrate_model_with_default_values if @view&.new?
        end

        unless self.class.model_class.present?
          if model_class.present? && model_class.respond_to?(:base_class)
            self.class.model_class = model_class.base_class
          end
        end

        # Instance option seam: apply overlay option overrides to THIS instance
        # only (class_attribute instance writers shadow the class value without
        # touching shared class state). Covers bare `.new(record:)`. `.dup`
        # copies these ivars from an already-applied instance, and `hydrate`
        # re-applies, so both paths carry overrides.
        apply_dynamic_config_options
      end

      def detect_fields
        self.items_holder = Avo::Resources::Items::Holder.new(parent: self)

        # Used in testing to replace items
        if temporary_items.present?
          instance_eval(&temporary_items)
        else
          fetch_fields
        end

        # Field seam: the provider may add/edit/remove/reorder items on the
        # per-instance holder AFTER fetch_fields completes (which runs any
        # avo-meta fetch_fields prepend), giving overlay-wins ordering
        # structurally.
        apply_dynamic_config_items

        self
      end

      # Renderable items for the resource view. Injects a header if none is
      # defined and, when the user hasn't taken control by declaring at least
      # one panel, wraps standalone field groups in a Panel + Card so they
      # render with the expected chrome at the top level.
      def get_items
        grouped_items = visible_items.slice_when do |prev, curr|
          is_standalone?(prev) != is_standalone?(curr)
        end.to_a.map do |group|
          {elements: group, is_standalone: is_standalone?(group.first)}
        end

        if items.none? { |item| item.is_header? }
          header = Avo::Resources::Items::Header.new
          hydrate_item header
          grouped_items.unshift({elements: [header], is_standalone: false})
        end

        if items.none? { |item| item.is_panel? }
          grouped_items.select { |group| group[:is_standalone] }.each do |group|
            calculated_panel = Avo::Resources::Items::Panel.new
            hydrate_item calculated_panel

            card = Avo::Resources::Items::Card.new
            hydrate_item card
            card.items_holder.items = group[:elements]
            calculated_panel.items_holder.items = [card]

            group[:elements] = calculated_panel
          end
        end

        grouped_items.flat_map { |group| group[:elements] }
      end

      unless defined? VIEW_METHODS_MAPPING
        VIEW_METHODS_MAPPING = {
          index: [:index, :display],
          show: [:show, :display],
          edit: [:edit, :form],
          update: [:edit, :form],
          new: [:new, :form],
          create: [:new, :form]
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
          return send(:"#{method_for_view}_fields") if respond_to?(:"#{method_for_view}_fields")
        end

        fields
      end

      def fetch_cards
        possible_methods_for_view = VIEW_METHODS_MAPPING[view.to_sym]

        possible_methods_for_view&.each do |method_for_view|
          return send(:"#{method_for_view}_cards") if respond_to?(:"#{method_for_view}_cards")
        end

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

          # Entity-bag seam: inject provider-supplied action/filter/scope
          # definitions into the per-instance loader bag.
          apply_dynamic_config_attachables(entity)

          entity_loader(entity).bag
        end

        # def get_action_arguments / def get_filter_arguments / def get_scope_arguments
        define_method :"get_#{entity}_arguments" do |entity_class|
          klass = send(:"get_#{plural_entity}").find { |entity| entity[:class].to_s == entity_class.to_s }

          raise "Couldn't find '#{entity_class}' in the 'def #{plural_entity}' method on your '#{self.class}' resource." if klass.nil?

          klass[:arguments]
        end
      end

      def find_action(action_id)
        actions = get_actions + Array(safe_call(:get_actions_from_custom_controls))

        actions
          .uniq { |action| action[:class].to_s }
          .find { |action| action[:class].to_s == action_id.to_s }
      end

      def hydrate(...)
        super

        if @record.present?
          hydrate_model_with_default_values if @view&.new?
        end

        # Re-apply overlay option overrides: `.dup` (association contexts) skips
        # `initialize`, and the controller hydrates the dup, so this is where a
        # dup'd instance picks up (or refreshes) its overrides.
        apply_dynamic_config_options

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

      def record_icon
        fetch_record_icon.to_s
      end

      def fetch_record_icon
        return icon if @record.nil?

        # Get the icon from the record if icon is not set
        return @record.try(:icon) if icon.nil?

        # If the icon is a symbol, get the value from the record else execute the block/string
        case icon
        when Symbol
          @record.send icon
        when Proc
          Avo::ExecutionContext.new(target: icon, resource: self, record: @record).handle
        end
      end

      def available_view_types
        @available_view_types ||= begin
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
      end

      def attachment_fields
        get_field_definitions.select do |field|
          [Avo::Fields::FileField, Avo::Fields::FilesField].include? field.class
        end
      end

      # Map the received params to their actual fields
      # 'resource' argument is used on avo-advanced, don't remove
      def fields_by_database_id(resource: self)
        resource.get_field_definitions
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
          # params at this point are already permitted, only need the keys to access them
          extra_attributes = permitted_params.slice(*flatten_keys(extra_params))

          # Let Rails fill in the rest of the params
          record.assign_attributes extra_attributes
        end

        safe_call(:fill_nested_records, record:, permitted_params:) || record
      end

      def authorization(user: nil)
        current_user = user || Avo::Current.user
        Avo::Services::AuthorizationService.new(current_user, record || model_class, policy_class: authorization_policy)
      end

      def file_hash
        content_to_be_hashed = ""

        file_base = self.class.class_name.underscore
        resource_path = Rails.root.join("app", "avo", "resources", "#{file_base}.rb").to_s
        if File.file? resource_path
          content_to_be_hashed += File.read(resource_path)
        end

        # policy file hash
        policy_path = Rails.root.join("app", "policies", "#{file_base.gsub("_resource", "")}_policy.rb").to_s
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

        # Mix in the overlay fingerprint so index/grid fragment caches bust on
        # overlay changes. Nil when no provider is installed, so today's key is
        # unchanged.
        fingerprint = Avo.dynamic_config_cache_fingerprint(self.class)
        result << fingerprint unless fingerprint.nil?

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

              if field.polymorphic_as.present? && field.types.map(&:to_s).include?(@params[:via_relation_class]) && @params[:via_record_id].present?
                # set the value to the actual record
                via_resource = Avo.resource_manager.get_resource_by_model_class(@params[:via_relation_class])
                value = via_resource.find_record(@params[:via_record_id]) if via_resource.present?
              elsif reflection.present? && reflection.foreign_key.present? && field.id.to_s == @params[:via_relation].to_s && @params[:via_record_id].present?
                resource = Avo.resource_manager.get_resource_by_model_class params[:via_relation_class]
                record = resource.find_record @params[:via_record_id], params: params if resource.present?
                id_param = reflection.options[:primary_key] || :id

                value = record.send(id_param) if record.present?
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

      def get_external_link
        return unless record&.persisted?

        Avo::ExecutionContext.new(target: external_link, resource: self, record: record).handle
      end

      def resource_type_array? = false

      def sort_by_param
        available_columns = model_class.column_names

        if available_columns.include?(default_sort_column.to_s)
          default_sort_column
        elsif available_columns.include?("created_at")
          :created_at
        end
      end

      def sorting_supported? = true

      def view_type
        @view_type ||= if @params[:view_type].present?
          Avo::ViewInquirer.new(@params[:view_type])
        elsif available_view_types.size == 1
          Avo::ViewInquirer.new(available_view_types.first)
        else
          Avo::ViewInquirer.new(Avo::ExecutionContext.new(
            target: default_view_type || Avo.configuration.default_view_type,
            resource: self,
            view: @view
          ).handle)
        end
      end

      private

      # Apply overlay option overrides to this instance. Locked options are
      # skipped core-side, so a lock holds even against a buggy provider. Values
      # are written through the class_attribute instance writers, shadowing the
      # class value for this instance only.
      def apply_dynamic_config_options
        Avo.apply_dynamic_config(nil) do |provider|
          overrides = provider.entity_options_for(self.class)
          next unless overrides.is_a?(Hash) && overrides.any?

          overrides.each do |option, value|
            # Enforce the allowlist at the write site, not just the lock set: an
            # option classified excluded/not-overridable (id, abstract,
            # scopes_loader, …) has a public writer but must never be applied,
            # even if a buggy or hostile provider returns it.
            next unless self.class.dynamic_config_options.include?(option.to_sym)
            next if self.class.dynamic_config_locked_option?(option)

            writer = :"#{option}="
            public_send(writer, value) if respond_to?(writer)
          end
        end

        nil
      end

      # Let the provider mutate the per-instance items_holder (add/edit/remove/
      # reorder). The provider mutates in place; the return value is ignored.
      def apply_dynamic_config_items
        Avo.apply_dynamic_config(nil) { |provider| provider.items_for(self) }

        nil
      end

      # Inject provider-supplied entity definitions into the per-instance loader
      # bag for the given entity (:action / :filter / :scope).
      def apply_dynamic_config_attachables(entity)
        Avo.apply_dynamic_config(nil) do |provider|
          extras = provider.attachables_for(self, entity)
          next unless extras.is_a?(Array) && extras.any?

          loader = entity_loader(entity)
          extras.each { |definition| loader.use(definition) }
        end

        nil
      end

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
