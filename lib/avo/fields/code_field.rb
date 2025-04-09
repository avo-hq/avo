module Avo
  module Fields
    class CodeField < BaseField
      attr_reader :language
      attr_reader :theme
      attr_reader :height
      attr_reader :tab_size
      attr_reader :indent_with_tabs
      attr_reader :line_wrapping

      def initialize(id, **args, &block)
        hide_on :index

        if args[:pretty_generated]
          args[:format_using] ||= lambda do
            JSON.pretty_generate(JSON.parse(value.to_json))
          end
  
          args[:update_using] ||= lambda do
            JSON.parse(value)
          end
        end

        super(id, **args, &block)

        @language = args[:language].present? ? args[:language].to_s : "javascript"
        @theme = args[:theme].present? ? args[:theme].to_s : "default"
        @height = args[:height].present? ? args[:height].to_s : "auto"
        @tab_size = args[:tab_size].present? ? args[:tab_size] : 2
        @indent_with_tabs = args[:indent_with_tabs].present? ? args[:indent_with_tabs] : false
        @line_wrapping = args[:line_wrapping].present? ? args[:line_wrapping] : true
      end
    end
  end
end
