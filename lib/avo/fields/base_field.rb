module Avo
  module Fields
    class BaseField
      extend ActiveSupport::DescendantsTracker

      prepend Avo::Concerns::HasItemType
      prepend Avo::Concerns::IsResourceItem
      include Avo::Concerns::IsVisible
      include Avo::Concerns::VisibleInDifferentViews
      include Avo::Concerns::HasHelpers
      include Avo::Fields::Concerns::HasFieldName
      include Avo::Fields::Concerns::HasDefault
      include Avo::Fields::Concerns::HasHTMLAttributes
      include Avo::Fields::Concerns::HandlesFieldArgs
      include Avo::Fields::Concerns::IsReadonly
      include Avo::Fields::Concerns::IsDisabled
      include Avo::Fields::Concerns::IsRequired
      include Avo::Fields::Concerns::UseViewComponents

      include ActionView::Helpers::UrlHelper

      delegate :app, to: ::Avo::Current
      delegate :view_context, to: :app
      delegate :context, to: :app
      delegate :simple_format, :content_tag, to: :view_context
      delegate :main_app, to: :view_context
      delegate :avo, to: :view_context
      delegate :t, to: ::I18n

      # Private options
      attr_reader :id
      attr_reader :block
      attr_reader :computable # if allowed to be computable
      attr_reader :computed # if block is present
      attr_reader :computed_value # the value after computation
      attr_reader :copyable # if allowed to be copyable

      # Hydrated payload
      attr_accessor :record
      attr_accessor :action
      attr_accessor :user
      attr_accessor :panel_name

      class_attribute :field_name_attribute

      class << self
        # TODOS:
        # - Verify each field and certify that it only have the option that it uses
        #   - To simplify the process lets first put this PR on a state where it uses the new system but keeps the options as before (ensure tests passes)
        # - For each option complete: description / default value / possible values
        # - Make sure the default options hash only have options used on all the fields
        # - Find a way to handle complex options like nested
        # - Find a way to DRY group of options that are used across multiple fields but not all of them
        # - Create a option documentation template
        # - Adjust the field options file.md generator to follow that template
        # - Automate the generation process
        # - Connect it with the docs
        # - Possible nice to haves:
        #   - Warning on unsupported options, example: field :name, as: :text, attach_scope:...
        #   - Warning on unsupported type / value, example: field :name, as: :text, required: 2
        #   - Allow to override default / possible values etc...
        #   - execution_context getter + docs from option definition: supports :name, execution_context: {record: "record", field: "self", resource: "@resource"}

        def supports(option, args = {})
          self.supported_options[option] = args

          # if Avo::Fields::OPTIONS[option][:execution_context]...
            # define_method option.to_s do
            #   Avo::ExecutionContext.new(
            #     target: :"@#{option}"
            #   )
            # end
          # else
          unless respond_to?(option.to_s)
            define_method option.to_s do
              instance_variable_get(:"@#{option}")
            end
          end
          #end
        end
      end

      def initialize(id, **args, &block)
        @id = id
        @block = block
        @view = Avo::ViewInquirer.new(args[:view])
        @resource = args[:resource]
        @action = args[:action]
        @computable = true
        @computed = block.present?
        @computed_value = nil
        @value = args[:value]
        @args = args

        self.supported_options.each do |option, option_hash|
          instance_variable_set(
            :"@#{option}",
            args.has_key?(option) ? args[option] : option_hash[:default]
          )
        end

        post_initialize if respond_to?(:post_initialize)
      end

      def translation_key
        @translation_key || "avo.field_translations.#{@id}"
      end

      def translated_name(default:)
        t(translation_key, count: 1, default: default).humanize
      end

      def translated_plural_name(default:)
        t(translation_key, count: 2, default: default).humanize
      end

      # Getting the name of the resource (user/users, post/posts)
      # We'll first check to see if the user passed a name
      # Secondly we'll try to find a translation key
      # We'll fallback to humanizing the id
      def name
        if custom_name?
          Avo::ExecutionContext.new(target: @name).handle
        elsif translation_key
          translated_name default: default_name
        else
          default_name
        end
      end

      def plural_name
        default = name.pluralize

        if translation_key
          translated_plural_name default: default
        else
          default
        end
      end

      def table_header_label
        @table_header_label ||= name
      end

      def custom_name?
        !@name.nil?
      end

      def default_name
        @id.to_s.humanize(keep_id_suffix: true)
      end

      def placeholder
        Avo::ExecutionContext.new(target: @placeholder || name, record: record, resource: @resource, view: @view).handle
      end

      def value(property = nil)
        return @value if @value.present?

        property ||= @for_attribute || @id

        # Get record value
        final_value = @record.send(property) if is_model?(@record) && @record.respond_to?(property)

        # On new views and actions modals we need to prefill the fields with the default value if value is nil
        if final_value.nil? && should_fill_with_default_value? && @default.present?
          final_value = computed_default_value
        end

        # Run computable callback block if present
        if computable && @block.present?
          final_value = execute_context(@block)
        end

        # Run the value through resolver if present
        if @format_using.present?
          final_value = execute_context(@format_using, value: final_value)
        end

        if @decorate.present? && @view.display?
          final_value = execute_context(@decorate, value: final_value)
        end

        final_value
      end

      def execute_context(target, **extra_args)
        Avo::ExecutionContext.new(
          target:,
          record: @record,
          resource: @resource,
          view: @view,
          field: self,
          include: self.class.included_modules,
          **extra_args
        ).handle
      end

      # Fills the record with the received value on create and update actions.
      def fill_field(record, key, value, params)
        key = @for_attribute.to_s if @for_attribute.present?
        return record unless has_attribute?(record, key)

        record.public_send(:"#{key}=", apply_update_using(record, key, value, resource))

        record
      end

      def apply_update_using(record, key, value, resource)
        return value if @update_using.nil?

        Avo::ExecutionContext.new(
          target: @update_using,
          record:,
          key:,
          value:,
          resource:,
          field: self,
          include: self.class.included_modules
        ).handle
      end

      def has_attribute?(record, attribute)
        record.methods.include? attribute.to_sym
      end

      # Try to see if the field has a different database ID than it's name
      def database_id
        foreign_key
      rescue
        id
      end

      def has_own_panel?
        false
      end

      def resolve_attribute(value)
        value
      end

      def to_permitted_param
        id.to_sym
      end

      def record_errors
        record.present? ? record.errors : {}
      end

      def type
        @type ||= self.class.name.demodulize.to_s.underscore.gsub("_field", "")
      end

      def custom?
        !method(:initialize).source_location.first.include?("lib/avo/field")
      rescue
        true
      end

      def visible_in_reflection?
        true
      end

      def hidden_in_reflection?
        !visible_in_reflection?
      end

      def options_for_filter
        options
      end

      def updatable
        !is_disabled? && visible?
      end

      # Used by Avo to fill the record with the default value on :new and :edit views
      def assign_value(record:, value:)
        id = (type == "belongs_to") ? foreign_key : database_id

        if record.send(id).nil?
          record.send(:"#{id}=", value)
        end
      end

      def form_field_label
        id
      end

      def meta
        Avo::ExecutionContext.new(target: @meta, record: record, resource: @resource, view: @view).handle
      end

      private

      def model_or_class(model)
        model.instance_of?(String) ? "class" : "model"
      end

      def is_model?(model)
        model_or_class(model) == "model"
      end

      def should_fill_with_default_value?
        on_create? || in_action?
      end

      def on_create?
        @view.in?(%w[new create])
      end

      def in_action?
        @action.present?
      end

      def get_resource_by_model_class(model_class)
        resource = Avo.resource_manager.get_resource_by_model_class(model_class)

        resource || (raise Avo::MissingResourceError.new(model_class, self))
      end
    end
  end
end
