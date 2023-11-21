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
        Dir.glob(Rails.root.join("app", "views", "avo", "sidebar", "items", "*.html.erb"))
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
    end
  end
end
