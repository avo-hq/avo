module Avo
  module Fields
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
          view = view.to_sym if view.present?

          if [view, element].any?(&:nil?)
            default_attribute_value name
          end

          parsed = parse_html

          attributes = if parsed.is_a? Hash
            get_html_from_hash name, element: element, hash: parsed, view: view
          elsif parsed.is_a? Avo::HTML::Builder
            get_html_from_block name, element: element, html_builder: parsed, view: view
          elsif parsed.nil?
            # Handle empty parsed by returning an empty state
            default_attribute_value name
          end

          add_action_data_attributes(attributes, name, element)
          add_resource_data_attributes(attributes, name, element, view)

          attributes
        end

        private

        # Returns Hash, HTML::Builder, or nil.
        def parse_html
          return if @html.nil?

          if @html.is_a? Hash
            @html
          elsif @html.respond_to? :call
            Avo::HTML::Builder.parse_block(record: record, resource: resource, &@html)
          end
        end

        def default_attribute_value(name)
          name == :data ? {} : ""
        end

        def add_action_data_attributes(attributes, name, element)
          if can_add_stimulus_attributes_for?(action, attributes, name, element)
            attributes.merge!(stimulus_attributes_for(action))
          end
        end

        def add_resource_data_attributes(attributes, name, element, view)
          if can_add_stimulus_attributes_for?(resource, attributes, name, element) && view.in?([:edit, :new])
            resource_stimulus_attributes = stimulus_attributes_for(resource)

            attributes.merge!(resource_stimulus_attributes)
          end
        end

        def get_html_from_block(name = nil, element:, html_builder:, view:)
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

        def get_html_from_hash(name = nil, element:, hash:, view:)
          # @todo: what if this is not a Hash but a string?
          hash.dig(view, element, name) || {}
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

        def can_add_stimulus_attributes_for?(entity, attributes, name, element)
          !attributes.nil? && name == :data && element == :input && entity.present? && entity.respond_to?(:get_stimulus_controllers)
        end

        def stimulus_attributes_for(entity)
          entity.get_stimulus_controllers
            .split(" ")
            .map do |controller|
              [:"#{controller}-target", "#{id.to_s.underscore}_#{type.to_s.underscore}_input".camelize(:lower)]
            end
            .to_h
        end
      end
    end
  end
end
