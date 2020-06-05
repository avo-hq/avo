require_relative 'element'

module Avocado
  module Fields
    class Field
      include Avocado::Fields::Element

      attr_accessor :id
      attr_accessor :name
      attr_accessor :component
      attr_accessor :updatable
      attr_accessor :sortable
      attr_accessor :required
      attr_accessor :readonly
      attr_accessor :nullable
      attr_accessor :resolve_using
      attr_accessor :computable
      attr_accessor :is_array_param
      attr_accessor :block

      def initialize(id_or_name, **args, &block)
        super(id_or_name, **args, &block)
        @defaults ||= {}

        args = @defaults.merge(args).symbolize_keys

        # The field properties as a hash {property: default_value}
        @field_properties = {
          id: id_or_name.to_s.parameterize.underscore,
          name: id_or_name.to_s.camelize,
          block: block,
          component: 'field',
          required: false,
          readonly: false,
          updatable: true,
          sortable: false,
          nullable: false,
          computable: false,
          is_array_param: false,
          resolve_using: false,
        }

        # Set the values in the following order
        # - app defaults
        # - field defaults
        # - field option
        @field_properties.each do |name, default_value|
          final_value = args[name.to_sym]
          self.send("#{name}=", final_value.nil? || !defined?(final_value) ? default_value : final_value)
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
        fields[:value] = model[id] if model_or_class(model) == 'model'

        # Run each field's custom hydration
        fields.merge! self.hydrate_resource model, resource, view if self.methods.include? :hydrate_resource

        # Run callback block if present
        fields[:value] = @block.call model, resource, view, self if computable and @block.present?

        # Run the value through resolver if present
        fields[:value] = @resolve_using.call fields[:value] if @resolve_using.present?

        fields
      end

      def fill_model(model, key, value)
        model[key] = value

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
