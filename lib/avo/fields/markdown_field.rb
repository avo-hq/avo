module Avo
  module Fields
    class MarkdownField < BaseField
      attr_reader :rows

      def initialize(id, **args, &block)
        super(id, **args, &block)

        hide_on :index
        add_string_prop args, :rows, default: 20
      end

      def self.parser
        renderer = Redcarpet::Render::HTML.new(hard_wrap: true)
        Redcarpet::Markdown.new(renderer, lax_spacing: true, fenced_code_blocks: true, hard_wrap: true)
      end
    end
  end
end
