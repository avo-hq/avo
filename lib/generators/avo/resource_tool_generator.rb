require "fileutils"
require_relative "named_base_generator"

module Generators
  module Avo
    class ResourceToolGenerator < NamedBaseGenerator
      source_root File.expand_path("templates", __dir__)

      argument :name, type: :string, required: true

      namespace "avo:resource_tool"

      def handle
        # Add configuration file
        template "resource_tools/resource_tool.tt", "app/avo/resource_tools/#{file_name}.rb"

        # Add view file
        template "resource_tools/partial.tt", "app/views/avo/resource_tools/_#{file_name}.html.erb"
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
