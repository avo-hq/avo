require "rails/generators"
require "fileutils"

module Generators
  module Avo
    class ToolGenerator < ::Rails::Generators::Base
      argument :name, type: :string, required: true

      source_root File.expand_path("templates", __dir__)

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

        route <<-ROUTE
scope :#{::Avo.configuration.namespace} do
  get "#{file_name}", to: "avo/tools##{file_name}"
end
        ROUTE
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
