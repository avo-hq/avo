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
      attr_accessor :block

      def initialize(id_or_name, **args, &block)
        super(id_or_name, **args, &block)
        @defaults ||= {}

        args = @defaults.merge(args).symbolize_keys

        # The field properties as a hash {property: default_value}
        @field_properties = {
          name: id_or_name.to_s.camelize,
          component: 'field',
          required: false,
          readonly: false,
          updatable: true,
          sortable: false,
          required: false,
          nullable: false,
        }

        # Set the values in the following order
        # - app defaults
        # - field defaults
        # - field option
        @field_properties.each do |name, default_value|
          final_value = args[name.to_sym]
          self.send("#{name}=", final_value.nil? || !defined?(final_value) ? default_value : final_value)
        end

        @id = id_or_name.to_s.parameterize.underscore

        @block = block

        # Set the visibility
        show_on args[:show_on] if args[:show_on].present?
        hide_on args[:hide_on] if args[:hide_on].present?
        only_on args[:only_on] if args[:only_on].present?
        except_on args[:except_on] if args[:except_on].present?
      end

      def fetch_for_resource(model, view = :index)
        fields = {
          id: id,
          computed: block.present?,
        }

        @field_properties.each do |name, value|
          fields[name] = self.send(name)
        end

        fields[:db_value] = model[id] if model_or_class(model) == 'model'
        fields[:value] = model[id] if model_or_class(model) == 'model'

        fields
      end

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
