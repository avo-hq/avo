module Avo
  module Concerns
    module HasHtmlAttributes
      extend ActiveSupport::Concern

      attr_reader :html

      # Used to get attributes for elements and views
      #
      # examples:
      # get_html :data, view: :edit, element: :input
      # get_html :classes, view: :show, element: :wrapper
      # get_html :styles, view: :index, element: :wrapper
      def get_html(name = nil, element:, view:)
        return if [name, view, element, html_builder].any?(&:nil?)

        if html_builder.is_a? Hash
          get_html_from_hash name, element: element, view: view
        elsif html_builder.respond_to? :call
          get_html_from_block name, element: element, view: view
        end
      end

      private

      def get_html_from_block(name = nil, element:, view:)
        values = []

        # get view ancestor
        values << html_builder.dig_stack(view, element, name)
        # get element ancestor
        values << html_builder.dig_stack(element, name)
        # get direct ancestor
        values << html_builder.dig_stack(name)

        values_type = if [:data, :styles].include? name
          :hash
        elsif name == :classes
          :string
        end

        merge_values_as(as: values_type, values: values)
      end

      def get_html_from_hash(name = nil, element:, view:)
        html_builder.dig(view, element, name)
      end

      def html_builder
        return if @html.nil?

        if @html.is_a? Hash
          @html
        elsif @html.respond_to? :call
          Avo::Html::Builder.parse_block(record: model, &@html)
        end

      end

      def merge_values_as(as: :array, values: [])
        puts ["values->", values, as].inspect
        if as == :array
          values.flatten
        elsif as == :string
          values.select do |value|
            value.is_a? String
          end.join " "
        elsif as == :hash
          values.reduce({}, :merge)
        end
      end
    end
  end
end
