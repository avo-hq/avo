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
        ::Redcarpet::Markdown.new(
          ::Redcarpet::Render::HTML,
          tables: true,
          lax_spacing: true,
          fenced_code_blocks: true,
          space_after_headers: true,
          hard_wrap: true,
          autolink: true,
          strikethrough: true,
          underline: true,
          highlight: true,
          quote: true,
          with_toc_data: true
        )
      end
    end
  end
end
