require_relative "../base_generator"

module Generators
  module Avo
    module Js
      class InstallGenerator < BaseGenerator
        source_root File.expand_path("../templates", __dir__)

        namespace "avo:js:install"
        desc "Add custom JavaScript assets to your Avo project."

        # possible values: importmap or esbuild
        class_option :bundler, type: :string, default: "importmap"

        def create_files
          case options[:bundler].to_s
          when "importmap"
            install_for_importmap
          when "esbuild"
            install_for_esbuild
          else
            say "We don't know how to install Avo JS for this bundler \"#{options[:bundler]}\""
          end
        end

        no_tasks do
          def install_for_importmap
            unless Rails.root.join("app", "javascript", "avo.custom.js").exist?
              say "Add default app/javascript/avo.custom.js"
              copy_file template_path("avo.custom.js"), "app/javascript/avo.custom.js"
            end

            say "Ejecting the _head.html.erb partial"
            Rails::Generators.invoke("avo:eject", [":head", "--no-avo-version"], {destination_root: Rails.root})

            say "Adding the JS asset to the partial"
            append_to_file Rails.root.join("app", "views", "avo", "partials", "_head.html.erb"), "<%= javascript_importmap_tags \"avo.custom\" %>"

            # pin to importmap
            say "Pin the new entrypoint to your importmap config"
            append_to_file Rails.root.join("config", "importmap.rb"), "\n# Avo custom JS entrypoint\npin \"avo.custom\", preload: true\n"
          end

          def install_for_esbuild
            unless Rails.root.join("app", "javascript", "avo.custom.js").exist?
              say "Add default app/javascript/avo.custom.js"
              copy_file template_path("avo.custom.js"), "app/javascript/avo.custom.js"
            end

            say "Ejecting the _head.html.erb partial"
            Rails::Generators.invoke("avo:eject", [":head", "--no-avo-version"], {destination_root: Rails.root})

            say "Adding the JS asset to the partial"
            append_to_file Rails.root.join("app", "views", "avo", "partials", "_head.html.erb"), "<%= javascript_include_tag \"avo.custom\", \"data-turbo-track\": \"reload\", defer: true %>"
          end

          def template_path(filename)
            Pathname.new(__dir__).join("..", "templates", "js", filename).to_s
          end
        end
      end
    end
  end
end
