require "rails/generators"
require "fileutils"

module Generators
  module Avo
    class EjectGenerator < ::Rails::Generators::Base
      argument :filename, type: :string, required: true

      source_root ::Avo::Engine.root

      namespace "avo:eject"

      TEMPLATES = {
        sidebar: "app/views/avo/sidebar/_sidebar.html.erb"
      }

      def handle
        if @filename.starts_with?(":")
          template_id = path_to_sym @filename
          template_path = TEMPLATES[template_id]

          if path_exists? template_path
            eject template_path
          else
            say("Failed to find the `#{template_id.to_sym}` template.", :yellow)
          end
        elsif path_exists? @filename
          eject @filename
        else
          say("Failed to find the `#{@filename}` template.", :yellow)
        end
      end

      no_tasks do
        def path_to_sym(filename)
          template_id = filename.dup
          template_id[0] = ""
          template_id.to_sym
        end

        def path_exists?(path)
          path.present? && File.file?(::Avo::Engine.root.join(path))
        end

        def eject(path)
          copy_file ::Avo::Engine.root.join(path), ::Rails.root.join(path)
        end
      end
    end
  end
end
