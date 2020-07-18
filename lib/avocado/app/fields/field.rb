require_relative 'field_extensions/visible_in_different_views'

module Avocado
  module Fields
    class Field
      include Avocado::Fields::FieldExtensions::VisibleOnDifferentViews

      attr_accessor :id
      attr_accessor :name
      attr_accessor :component
      attr_accessor :updatable
      attr_accessor :sortable
      attr_accessor :required
      attr_accessor :readonly
      attr_accessor :nullable
      attr_accessor :null_values
      attr_accessor :format_using
      attr_accessor :computable
      attr_accessor :is_array_param
      attr_accessor :is_object_param
      attr_accessor :block
      attr_accessor :placeholder
      attr_accessor :help

      def initialize(id, **args, &block)
        super(id, **args, &block)
        @defaults ||= {}

        args = @defaults.merge(args).symbolize_keys

        null_values = [nil, '', *args[:null_values]]
        # The field properties as a hash {property: default_value}
        @field_properties = {
          id: id,
          name: id.to_s.humanize,
          block: block,
          component: 'field',
          required: false,
          readonly: false,
          updatable: true,
          sortable: false,
          nullable: false,
          null_values: null_values,
          computable: true,
          is_array_param: false,
          format_using: false,
          placeholder: id.to_s.camelize,
          help: nil,
        }

        # Set the values in the following order
        # - app defaults
        # - field defaults
        # - field option
        @field_properties.each do |name, default_value|
          final_value = args[name.to_sym]
          self.send("#{name}=", name != 'null_values' && (final_value.nil? || !defined?(final_value)) ? default_value : final_value)
        end

        # Set the visibility
        show_on args[:show_on] if args[:show_on].present?
        hide_on args[:hide_on] if args[:hide_on].present?
        only_on args[:only_on] if args[:only_on].present?
        except_on args[:except_on] if args[:except_on].present?
      end

      def fetch_for_resource(model, resource, view)
        fields = {
          id: id,
          computed: block.present?,
        }

        # Fill the properties with values
        @field_properties.each do |name, value|
          fields[name] = self.send(name)
        end

        # Set initial value
        fields[:value] = model.send(id) if model_or_class(model) == 'model' and model.methods.include? id

        # Run callback block if present
        if computable and @block.present?
          fields[:computed_value] = @block.call model, resource, view, self

          fields[:value] = fields[:computed_value]
        end

        # Run each field's custom hydration
        fields.merge! self.hydrate_field(fields, model, resource, view)

        # Run the value through resolver if present
        fields[:value] = @format_using.call fields[:value] if @format_using.present?

        fields
      end

      def hydrate_field(fields, model, resource, view)
        final_value = fields[:value]

        if fields[:computed_value].present?
          final_value = fields[:computed_value]
        end

        {
          value: final_value
        }
      end

      def fill_field(model, key, value)
        return model unless model.methods.include? key.to_sym

        model.send("#{key}=", value)

        model
      end

      # Try to see if the field has a different database ID than it's name
      def database_id(model)
        begin
          foreign_key(model)
        rescue => exception
          id
        end
      end

      def has_own_panel?
        false
      end

      private
        def model_or_class(model)
          if model.class == String
            return 'class'
          else
            return 'model'
          end
        end
    end
  end
end
