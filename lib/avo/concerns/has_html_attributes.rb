module Avo
  module Concerns
    module HasHTMLAttributes
      extend ActiveSupport::Concern

      attr_reader :html

      # Used to get attributes for elements and views
      #
      # examples:
      # get_html :data, view: :edit, element: :input
      # get_html :classes, view: :show, element: :wrapper
      # get_html :styles, view: :index, element: :wrapper
      def get_html(name = nil, element:, view:)
        if [view, element].any?(&:nil?) || Avo::App.license.lacks_with_trial(:stimulus_js_integration)
          default_attribute_value name
        end

        attributes = if html_builder.is_a? Hash
          get_html_from_hash name, element: element, view: view
        elsif html_builder.is_a? Avo::HTML::Builder
          get_html_from_block name, element: element, view: view
        elsif html_builder.nil?
          # Handle empty html_builder by returning an empty state
          default_attribute_value name
        end

        add_default_data_attributes attributes, name, element, view
      end

      private

      def html_builder
        return @parsed_html if @parsed_html.present?

        return if @html.nil?

        # Memoize the value
        @parsed_html = if @html.is_a? Hash
          @html
        elsif @html.respond_to? :call
          Avo::HTML::Builder.parse_block(record: model, resource: resource, &@html)
        end

        @parsed_html
      end

      def default_attribute_value(name)
        name == :data ? {} : ""
      end

      def add_default_data_attributes(attributes, name, element, view)
        if !attributes.nil? && name == :data && element == :input && view.in?([:edit, :new]) && resource.present? && resource.respond_to?(:get_stimulus_controllers)
          extra_attributes = resource.get_stimulus_controllers
            .split(" ")
            .map do |controller|
              [:"#{controller}-target", "#{id.to_s.underscore}_#{type.to_s.underscore}_input".camelize(:lower)]
            end
            .to_h

          attributes.merge extra_attributes
        else
          attributes
        end
      end

      def get_html_from_block(name = nil, element:, view:)
        values = []

        # get view ancestor
        values << html_builder.dig_stack(view, element, name)
        # get element ancestor
        values << html_builder.dig_stack(element, name)
        # get direct ancestor
        values << html_builder.dig_stack(name)

        values_type = if name == :data
          :hash
        else
          :string
        end

        merge_values_as(as: values_type, values: values)
      end

      def get_html_from_hash(name = nil, element:, view:)
        # @todo: what if this is not a Hash but a string?
        html_builder.dig(view, element, name) || {}
      end

      # Merge the values from all possible locations.
      # If the result is "blank", return nil so the attributes are not outputted to the DOM.
      #
      # Ex: if the style attribute is empty return `nil` instead of an empty space `" "`
      def merge_values_as(as: :array, values: [])
        result = if as == :array
          values.flatten
        elsif as == :string
          values.select do |value|
            value.is_a? String
          end.join " "
        elsif as == :hash
          values.reduce({}, :merge)
        end

        result if result.present?
      end
    end
  end
end
