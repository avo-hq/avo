module Avo
  module Fields
    class BaseField
      extend ActiveSupport::DescendantsTracker
      extend Avo::Fields::FieldExtensions::HasFieldName

      include Avo::Concerns::IsResourceItem
      include Avo::Concerns::HandlesFieldArgs

      include ActionView::Helpers::UrlHelper
      include Avo::Fields::FieldExtensions::VisibleInDifferentViews

      include Avo::Concerns::HandlesFieldArgs
      include Avo::Concerns::HasHTMLAttributes
      include Avo::Fields::Concerns::IsRequired

      delegate :view_context, to: ::Avo::App
      delegate :simple_format, :content_tag, to: :view_context
      delegate :main_app, to: :view_context
      delegate :avo, to: :view_context
      delegate :t, to: ::I18n

      attr_reader :id
      attr_reader :block
      attr_reader :required
      attr_reader :readonly
      attr_reader :sortable
      attr_reader :nullable
      attr_reader :null_values
      attr_reader :format_using
      attr_reader :help
      attr_reader :default
      attr_reader :visible
      attr_reader :as_label
      attr_reader :as_avatar
      attr_reader :as_description
      attr_reader :index_text_align

      # Private options
      attr_reader :updatable
      attr_reader :computable # if allowed to be computable
      attr_reader :computed # if block is present
      attr_reader :computed_value # the value after computation

      # Hydrated payload
      attr_reader :model
      attr_reader :view
      attr_reader :resource
      attr_reader :action
      attr_reader :user
      attr_reader :panel_name

      class_attribute :field_name_attribute
      class_attribute :item_type, default: :field

      def initialize(id, **args, &block)
        super(id, **args, &block)

        @id = id
        @name = args[:name]
        @translation_key = args[:translation_key]
        @block = block
        @required = args[:required] || false
        @readonly = args[:readonly] || false
        @sortable = args[:sortable] || false
        @nullable = args[:nullable] || false
        @null_values = args[:null_values] || [nil, ""]
        @format_using = args[:format_using] || nil
        @placeholder = args[:placeholder]
        @help = args[:help] || nil
        @default = args[:default] || nil
        @visible = args[:visible] || true
        @as_label = args[:as_label] || false
        @as_avatar = args[:as_avatar] || false
        @as_description = args[:as_description] || false
        @index_text_align = args[:index_text_align] || :left
        @html = args[:html] || nil

        @args = args

        @updatable = true
        @computable = true
        @computed = block.present?
        @computed_value = nil

        # Set the visibility
        show_on args[:show_on] if args[:show_on].present?
        hide_on args[:hide_on] if args[:hide_on].present?
        only_on args[:only_on] if args[:only_on].present?
        except_on args[:except_on] if args[:except_on].present?
      end

      def hydrate(model: nil, resource: nil, action: nil, view: nil, panel_name: nil, user: nil)
        @model = model if model.present?
        @view = view if view.present?
        @resource = resource if resource.present?
        @action = action if action.present?
        @user = user if user.present?
        @panel_name = panel_name if panel_name.present?

        self
      end

      def translation_key
        return @translation_key if @translation_key.present?

        "avo.field_translations.#{@id}"
      end

      # Getting the name of the resource (user/users, post/posts)
      # We'll first check to see if the user passed a name
      # Secondly we'll try to find a translation key
      # We'll fallback to humanizing the id
      def name
        return @name if custom_name?

        if translation_key && ::Avo::App.translation_enabled
          t(translation_key, count: 1, default: default_name).capitalize
        else
          default_name
        end
      end

      def plural_name
        default = name.pluralize

        if translation_key && ::Avo::App.translation_enabled
          t(translation_key, count: 2, default: default).capitalize
        else
          default
        end
      end

      def custom_name?
        @name.present?
      end

      def default_name
        @id.to_s.humanize(keep_id_suffix: true)
      end

      def placeholder
        return @placeholder if @placeholder.present?

        name
      end

      def visible?
        if visible.present? && visible.respond_to?(:call)
          visible.call resource: @resource
        else
          visible
        end
      end

      def value(property = nil)
        property ||= id

        # Get model value
        final_value = @model.send(property) if (model_or_class(@model) == "model") && @model.respond_to?(property)

        # On new views and actions modals we need to prefill the fields
        if (@view === :new) || @action.present?
          if default.present?
            final_value = if default.respond_to?(:call)
              default.call
            else
              default
            end
          end
        end

        # Run computable callback block if present
        if computable && block.present?
          final_value = instance_exec(@model, @resource, @view, self, &block)
        end

        # Run the value through resolver if present
        final_value = instance_exec(final_value, &@format_using) if @format_using.present?

        final_value
      end

      def fill_field(model, key, value, params)
        return model unless model.methods.include? key.to_sym

        model.send("#{key}=", value)

        model
      end

      # Try to see if the field has a different database ID than it's name
      def database_id(model)
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

      def view_component_name
        "#{type.camelize}Field"
      end

      # Try and build the component class or fallback to a blank one
      def component_for_view(view = :index)
        # Use the edit variant for all "update" views
        view = :edit if view.in? [:new, :create, :update]

        component_class = "::Avo::Fields::#{view_component_name}::#{view.to_s.camelize}Component"
        component_class.constantize
      rescue
        # When returning nil, a race condition happens and throws an error in some environments.
        # See https://github.com/avo-hq/avo/pull/365
        ::Avo::BlankFieldComponent
      end

      def model_errors
        return {} if model.nil?

        model.errors
      end

      def type
        self.class.name.demodulize.to_s.underscore.gsub("_field", "")
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

      private

      def model_or_class(model)
        if model.instance_of?(String)
          "class"
        else
          "model"
        end
      end
    end
  end
end
