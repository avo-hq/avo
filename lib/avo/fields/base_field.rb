module Avo
  module Fields
    class BaseField
      extend ActiveSupport::DescendantsTracker
      extend Avo::Fields::FieldExtensions::HasFieldName
      include Avo::Fields::FieldExtensions::VisibleInDifferentViews

      attr_accessor :id
      attr_accessor :name
      attr_accessor :translation_key
      attr_accessor :partial_name
      attr_accessor :partial_path
      attr_accessor :updatable
      attr_accessor :sortable
      attr_accessor :required
      attr_accessor :readonly
      attr_accessor :nullable
      attr_accessor :null_values
      attr_accessor :format_using
      attr_accessor :computed # if block is present
      attr_accessor :computable # if allowed to be computable
      attr_accessor :computed_value # the value after computation
      attr_accessor :block
      attr_accessor :placeholder
      attr_accessor :help
      attr_accessor :default
      attr_accessor :visible
      attr_accessor :model
      attr_accessor :resource
      attr_accessor :view
      attr_accessor :user
      attr_accessor :action
      attr_accessor :meta
      attr_accessor :panel_name
      attr_accessor :link_to_resource

      class_attribute :field_name_attribute

      @meta = {}

      def initialize(id, **args, &block)
        super(id, **args, &block)
        @defaults ||= {}

        args = @defaults.merge(args).symbolize_keys

        null_values = [nil, "", *args[:null_values]]
        # The field properties as a hash {property: default_value}
        @field_properties = {
          id: id,
          name: id.to_s.humanize(keep_id_suffix: true),
          translation_key: nil,
          block: block,
          partial_name: "field",
          required: false,
          readonly: false,
          updatable: true,
          sortable: false,
          nullable: false,
          null_values: null_values,
          computable: true,
          computed: block.present?,
          computed_value: false,
          format_using: false,
          placeholder: id.to_s.humanize,
          help: nil,
          default: nil,
          visible: true,
          meta: {},
          panel_name: nil
        }

        # Set the values in the following order
        # - app defaults
        # - field defaults
        # - field option
        @field_properties.each do |name, default_value|
          final_value = args[name.to_sym]
          send("#{name}=", name != "null_values" && (final_value.nil? || !defined?(final_value)) ? default_value : final_value)
        end

        # Set the visibility
        show_on args[:show_on] if args[:show_on].present?
        hide_on args[:hide_on] if args[:hide_on].present?
        only_on args[:only_on] if args[:only_on].present?
        except_on args[:except_on] if args[:except_on].present?

        if args[:use_partials].present?
          @custom_partials = args[:use_partials]
        end
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

      def visible?
        if visible.present? && visible.respond_to?(:call)
          visible.call resource: resource
        else
          visible
        end
      end

      def value
        # Get model value
        final_value = @model.send(id) if (model_or_class(@model) == "model") && @model.respond_to?(id)

        if (@view === :new) || @action.present?
          final_value = if default.present? && default.respond_to?(:call)
            default.call
          else
            default
          end
        end

        # Run callback block if present
        if computable && block.present?
          final_value = block.call @model, @resource, @view, self
        end

        # Run the value through resolver if present
        final_value = @format_using.call final_value if @format_using.present?

        final_value
      end

      def fill_field(model, key, value)
        return model unless model.methods.include? key.to_sym

        model.send("#{key}=", value)

        model
      end

      def partial_path_for(view)
        return @custom_partials[view] if @custom_partials.present? && @custom_partials[view].present?

        "avo/fields/#{view}/#{partial_name}"
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

      def component_name(view = :index)
        "Avo::#{view.to_s.classify}::Fields::#{partial_name.gsub("-field", "").underscore.camelize}FieldComponent"
      end

      def model_errors
        return {} if model.nil?

        model.errors
      end

      def type
        self.class.name.demodulize.to_s.underscore.gsub("_field", "")
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
