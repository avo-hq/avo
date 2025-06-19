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

        @grouped_options = args[:grouped_options]
        @enum = args[:enum]
        @multiple = args[:multiple]
        @display_value = args[:display_value] || false
      end

      def grouped_options
        Avo::ExecutionContext.new(
          target: @grouped_options,
          record: record,
          resource: resource,
          view: view,
          field: self
        ).handle
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
        return "—" if value.nil? || (@multiple && value.empty?)

        # Handle grouped options first
        if @grouped_options.present?
          return label_from_grouped_options
        end

        # If options are array don't need any pre-process
        if options.is_a?(Array)
          return @multiple ? value.join(", ") : value
        end

        # If options are enum and display_value is true we return the Value of that key-value pair, else return key of that key-value pair
        # WARNING: value here is the DB stored value and not the value of a key-value pair.
        if @enum.present?
          return @enum[value] if display_value
          return value
        end

        # When code arrive here it means options are Hash
        # If display_value is true we only need to return the value stored in DB
        if display_value
          value
        elsif @multiple
          options.select { |_, v| value.include?(v.to_s) }.keys.join(", ")
        else
          options.invert[value]
        end
      end

      def to_permitted_param
        @multiple ? {"#{id}": []} : id
      end

      def fill_field(record, key, value, params)
        if @multiple
          value = value.reject(&:blank?)
        end

        super
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

      def label_from_grouped_options
        grouped_opts = grouped_options
        return value.to_s unless grouped_opts.is_a?(Hash)

        if @multiple
          # Handle multiple values
          labels = Array.wrap(value).map do |val|
            find_label_in_grouped_options(grouped_opts, val) || val.to_s
          end

          labels.join(", ")
        else
          # Handle single value
          find_label_in_grouped_options(grouped_opts, value) || value.to_s
        end
      end

      def find_label_in_grouped_options(grouped_opts, search_value)
        grouped_opts.each do |group_name, group_options|
          # Skip if group_options is not a hash (malformed data)
          next unless group_options.is_a?(Hash)

          # Search within this group
          group_options.each do |label, option_value|
            # Convert both values to strings for comparison to handle different types
            if option_value.to_s == search_value.to_s
              return display_value ? option_value.to_s : label.to_s
            end
          end
        end

        # If not found in any group, return nil so the caller can handle it
        nil
      end
    end
  end
end
