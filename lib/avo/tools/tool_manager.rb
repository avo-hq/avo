module Avo
  module Tools
    class ToolManager
      class << self
        def build
          new
        end
      end

      # Insert any partials that we find in app/views/avo/sidebar/items.
      def get_sidebar_partials
        tool_sidebar_partials
          .map do |path|
            File.basename path
          end
          .map do |filename|
            # remove the leading underscore (_)
            filename[0] = ""
            # remove the extension
            filename.gsub!(".html.erb", "")
            filename
          end
      end

      def tools_for_navigation
        get_sidebar_partials
      end

      def tool_partials
        tool_sidebar_partials.map do |filename|
          segments = filename
            .gsub(".html.erb", "")
            .gsub(Rails.root.join("app", "views").to_s, "")
            .split("/")
          last_segment = segments.pop.sub("_", "")

          segments.append last_segment

          segments.join("/")
        end
      end

      private

      def tool_sidebar_partials
        Dir.glob(Rails.root.join("app", "views", "avo", "sidebar", "items", "*.html.erb"))
      end
    end
  end
end
