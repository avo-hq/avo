module Avo
  module Fields
    class CodeField < BaseField
      resizable_editor target: ".CodeMirror"

      attr_reader :language
      attr_reader :theme
      attr_reader :height
      attr_reader :tab_size
      attr_reader :indent_with_tabs
      attr_reader :line_wrapping
      attr_reader :always_show

      def initialize(id, **args, &block)
        hide_on :index

        if args[:pretty_generated]
          args[:format_using] ||= -> { value.blank? ? value : JSON.pretty_generate(value) }
          args[:update_using] ||= -> { value.blank? ? value : JSON.parse(value) }
        end

        super

        @language = args[:language].present? ? args[:language].to_s : "javascript"
        @theme = args[:theme].present? ? args[:theme].to_s : "default"
        @height = args[:height].present? ? args[:height].to_s : "auto"
        @tab_size = args[:tab_size].present? ? args[:tab_size] : 2
        @indent_with_tabs = args[:indent_with_tabs].present? ? args[:indent_with_tabs] : false
        @line_wrapping = args[:line_wrapping].present? ? args[:line_wrapping] : true
        @always_show = args[:always_show] || false
      end
    end
  end
end
