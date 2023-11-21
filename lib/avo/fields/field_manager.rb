module Avo
  module Fields
    class FieldManager
      class << self
        def build
          instance = new
          instance.init_fields
          instance
        end
      end

      attr_reader :fields

      def initialize
        @fields = []
      end

      def all
        fields
          .map do |field|
            field[:name] = field[:name].to_s

            field
          end
          .uniq do |field|
            field[:name]
          end
      end

      # This method will find all fields available in the Avo::Fields namespace and add them to the fields class_variable array
      # so later we can instantiate them on our resources.
      #
      # If the field has their `def_method` set up it will follow that convention, if not it will snake_case the name:
      #
      # Avo::Fields::TextField -> text
      # Avo::Fields::DateTimeField -> date_time
      def init_fields
        Avo::Fields::BaseField.descendants.each do |class_name|
          next if class_name.to_s == "BaseField"

          if class_name.to_s.end_with? "Field"
            load_field class_name.get_field_name, class_name
          end
        end
      end

      def load_field(method_name, klass)
        fields.push(
          name: method_name.to_s,
          class: klass
        )
      end
    end
  end
end
