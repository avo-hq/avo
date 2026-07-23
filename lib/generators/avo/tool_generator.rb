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
        # If there's no `mount_avo` (or the line can't be safely rewritten), fall back to a
        # standalone Avo engine routes block.
        routes_path = "config/routes.rb"
        routes_content = File.read(Rails.root.join(routes_path))
        route_definition = "get \"#{file_name}\", to: \"tools##{file_name}\", as: :#{file_name}"
        mount_avo_line = routes_content.lines.find { |line| line.match?(/^[ \t]*mount_avo\b/) }
        mount_avo = mount_avo_line && analyze_routes_line(mount_avo_line)

        if mount_avo && mount_avo[:block]
          # `mount_avo do` is already a block → inject the route as its first line.
          indent = mount_avo_line[/^[ \t]*/] + "  "
          inject_into_file routes_path, after: /^[ \t]*mount_avo\b.*\n/ do
            "#{indent}#{route_definition}\n"
          end
        elsif mount_avo && mount_avo[:complete]
          # `mount_avo` one-liner → wrap it into a block around the new route.
          indent = mount_avo_line[/^[ \t]*/]
          inner = indent + "  "
          gsub_file routes_path, /^[ \t]*mount_avo\b.*$/ do |line|
            code, comment = analyze_routes_line(line).values_at(:code, :comment)
            trailing = comment.empty? ? "" : " #{comment}"
            "#{code.rstrip} do#{trailing}\n#{inner}#{route_definition}\n#{indent}end"
          end
        else
          # No `mount_avo`, or a line we can't safely rewrite (multi-line call, unterminated
          # string) → fall back to a standalone Avo engine routes block.
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

        # Splits a routes.rb line into its `code` and trailing `comment` parts while
        # respecting string literals, and reports whether the line already opens a `do`
        # block (`block`) and whether it's a complete single-line statement we can rewrite
        # (`complete`). Returns nil when the line has an unterminated string — i.e. a
        # multi-line call — so callers fall back to a standalone routes block instead of
        # corrupting the file. Blanking string *contents* means a `#` or `do` inside a
        # string is never mistaken for a comment or a block opener.
        def analyze_routes_line(line)
          masked = +"" # code with string contents blanked and the comment dropped
          comment_at = nil # index of the `#` that starts a real (non-string) comment
          quote = nil
          line.chars.each_with_index do |char, index|
            if quote
              masked << ((char == quote) ? char : " ")
              quote = nil if char == quote
            elsif char == "\"" || char == "'"
              quote = char
              masked << char
            elsif char == "#"
              comment_at = index
              break
            else
              masked << char
            end
          end
          return nil if quote # unterminated string → multi-line statement

          {
            code: comment_at ? line[0...comment_at] : line,
            comment: comment_at ? line[comment_at..].strip : "",
            block: masked.match?(/\bdo\b\s*(\|[^|]*\|)?\s*\z/),
            complete: !masked.rstrip.end_with?(",")
          }
        end
      end
    end
  end
end
