require "fileutils"
require_relative "base_generator"

module Generators
  module Avo
    class ToolGenerator < BaseGenerator
      source_root File.expand_path("templates", __dir__)

      argument :name, type: :string, required: true

      namespace "avo:tool"

      def handle
        # Sidebar items
        template "tool/sidebar_item.tt", "app/views/avo/sidebar/items/_#{file_name}.html.erb"

        # Add controller if it doesn't exist
        controller_path = "app/controllers/avo/tools_controller.rb"
        unless File.file?(Rails.root.join(controller_path))
          template "tool/controller.tt", controller_path
        end

        # Add controller method
        inject_into_class controller_path, "Avo::ToolsController" do
          <<-METHOD
  def #{file_name}
    @page_title = "#{human_name}"
    add_breadcrumb "#{human_name}"
  end
          METHOD
        end

        # Add view file
        template "tool/view.tt", "app/views/avo/tools/#{file_name}.html.erb"

        # Add the route in the `routes.rb` file.
        # The route should be defined inside the Avo engine.
        # The new tool has a dedicated path helper.
        # EX:
        #   bin/rails generate avo:tool lolo
        #   will generate the avo.lolo_path helper
        # THe fact that it will always generate the definded? and Avo::Engine.routes.draw wraps is unfortunate. We'd love a PR to fix that.
        route_contents = <<~ROUTE
          
          if defined? ::Avo
            Avo::Engine.routes.draw do
              # This route is not protected, secure it with authentication if needed.
              get "#{file_name}", to: "tools##{file_name}", as: :#{file_name}
            end
          end
        ROUTE
        append_to_file "config/routes.rb", route_contents

        # Restart the server so the new routes go into effect.
        Rails::Command.invoke "restart"
      end

      no_tasks do
        def file_name
          name.to_s.underscore
        end

        def controller_name
          file_name.to_s
        end

        def human_name
          file_name.humanize
        end

        def in_code(text)
          "<code class='p-1 rounded bg-gray-500 text-white text-sm'>#{text}</code>"
        end
      end
    end
  end
end
