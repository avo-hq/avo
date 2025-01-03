module Avo
  module Fields
    class SelectField < BaseField
      include Avo::Fields::FieldExtensions::HasIncludeBlank

      attr_reader :display_value, :multiple

      def initialize(id, **args, &block)
        args[:placeholder] ||= I18n.t("avo.choose_an_option")

        super(id, **args, &block)

        @options = if args[:options].is_a? Hash
          ActiveSupport::HashWithIndifferentAccess.new args[:options]
        elsif args[:enum].present?
          args[:enum]
        else
          args[:options]
        end

        @enum = args[:enum]
        @multiple = args[:multiple]
        @display_value = args[:display_value] || false
      end

      def options_for_select
        # If options are array don't need any pre-process
        return options if options.is_a?(Array)

        # If options are enum we invert the enum if display value, else (see next comment)
        if @enum.present?
          return @enum.invert if display_value

          # We need to use the label attribute as the option value because Rails casts it like that
          return @enum.map { |label, value| [label, label] }.to_h
        end

        # When code arrive here it means options are Hash
        # If display_value is true we only need to return the values of the Hash
        display_value ? options.values : options
      end

      def label
        # If options are array don't need any pre-process
        return value if options.is_a?(Array)

        # If options are enum and display_value is true we return the Value of that key-value pair, else return key of that key-value pair
        # WARNING: value here is the DB stored value and not the value of a key-value pair.
        if @enum.present?
          return @enum[value] if display_value
          return value
        end

        # When code arrive here it means options are Hash
        # If display_value is true we only need to return the value stored in DB
        display_value ? value : options.invert[value]
      end

      def to_permitted_param
        case id
          when :sizes
            {"#{id}": []}
          else
            id
          end
      end

      private

      def options
        Avo::ExecutionContext.new(
          target: @options,
          record: record,
          resource: resource,
          view: view,
          field: self
        ).handle
      end
    end
  end
end
