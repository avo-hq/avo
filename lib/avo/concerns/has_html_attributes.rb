module Avo
  module Concerns
    module HasHtmlAttributes
      extend ActiveSupport::Concern

      included do
      end

      class_methods do
      end

      attr_reader :html

      # def data_attributes(**args)
      #   get_html :data, **args
      # end

      # def classes_attributes(**args)
      #   get_html :classes, **args
      # end

      # def style_attributes(**args)
      #   get_html :style, **args
      # end

      # Used to get attributes for elements and views
      #
      # examples:
      # get_html :data, view: :edit, element: :input
      # get_html :classes, view: :show, element: :wrapper
      # get_html :styles, view: :index, element: :wrapper
      def get_html(name = nil, element:, view:)
        return if [name, view, element, html_builder].any?(&:nil?)

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

      private

      def html_builder
        return if @html.nil?

        Avo::Html::Builder.parse_block(record: model, &@html)
      end

      def merge_values_as(as: :array, values: [])
        if as == :array
          values.flatten
        elsif as == :string
          values.join " "
        elsif as == :hash
          merged = {}

          values.each do |val|
            merged.merge! val
          end

          merged
        end
      end
    end
  end
end
