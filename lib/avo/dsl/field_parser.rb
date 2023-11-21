module Avo
  module Dsl
    class FieldParser
      attr_reader :as
      attr_reader :args
      attr_reader :id
      attr_reader :block
      attr_reader :instance
      attr_reader :order_index

      def initialize(id:, order_index: 0, **args, &block)
        @id = id
        @as = args.fetch(:as, :text)
        @order_index = order_index
        @args = args
        @block = block
        @instance = nil
      end

      def valid?
        instance.present?
      end

      def invalid?
        !valid?
      end

      def parse
        # The field is passed as a symbol eg: :text, :color_picker, :trix
        @instance = if as.is_a? Symbol
          parse_from_symbol
        elsif as.is_a? Class
          parse_from_class
        end

        self
      end

      private

      def parse_from_symbol
        field_class = field_class_from_symbol(as)

        if field_class.present?
          # The field has been registered before.
          instantiate_field(id, klass: field_class, **args, &block)
        else
          # The symbol can be transformed to a class and found.
          class_name = as.to_s.camelize
          field_class = "Avo::Fields::#{class_name}Field"

          # Discover & load custom field classes
          if Object.const_defined? field_class
            instantiate_field(id, klass: field_class.safe_constantize, **args, &block)
          end
        end
      end

      def parse_from_class
        # The field has been passed as a class.
        if Object.const_defined? as.to_s
          instantiate_field(id, klass: as, **args, &block)
        end
      end

      def instantiate_field(id, klass:, **args, &block)
        if block
          klass.new(id, **args || {}, &block)
        else
          klass.new(id, **args || {})
        end
      end

      def field_class_from_symbol(symbol)
        matched_field = Avo.field_manager.all.find do |field|
          field[:name].to_s == symbol.to_s
        end

        return matched_field[:class] if matched_field.present? && matched_field[:class].present?
      end
    end
  end
end
