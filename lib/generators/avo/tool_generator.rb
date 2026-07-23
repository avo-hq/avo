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
    add_breadcrumb title: "#{human_name}"
  end
          METHOD
        end

        # Add view file
        template "tool/view.tt", "app/views/avo/tools/#{file_name}.html.erb"

        # Add the route inside the `mount_avo` block so it gets the `avo.#{file_name}_path` helper.
        # If `mount_avo` is a one-liner, turn it into a block. If it's already a block, inject into it.
        # If there's no `mount_avo` at all, fall back to a standalone Avo engine routes block.
        routes_path = "config/routes.rb"
        routes_content = File.read(Rails.root.join(routes_path))
        route_definition = "get \"#{file_name}\", to: \"tools##{file_name}\", as: :#{file_name}"

        if (match = routes_content.match(/^([ \t]*)mount_avo\b.*\bdo\b.*$/))
          indent = match[1] + "  "
          inject_into_file routes_path, after: /^[ \t]*mount_avo\b.*\bdo\b.*\n/ do
            "#{indent}#{route_definition}\n"
          end
        elsif (match = routes_content.match(/^([ \t]*)mount_avo\b.*$/))
          indent = match[1]
          inner = indent + "  "
          gsub_file routes_path, /^[ \t]*mount_avo\b.*$/ do |line|
            "#{line} do\n#{inner}#{route_definition}\n#{indent}end"
          end
        else
          append_to_file routes_path, <<~ROUTE

            if defined? ::Avo
              Avo::Engine.routes.draw do
                #{route_definition}
              end
            end
          ROUTE
        end

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
          "<code class='p-1 rounded-sm bg-gray-500 text-white text-sm'>#{text}</code>"
        end
      end
    end
  end
end
