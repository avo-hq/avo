require_relative "../base_generator"

module Generators
  module Avo
    module Tailwindcss
      class InstallGenerator < BaseGenerator
        source_root File.expand_path("../templates", __dir__)

        namespace "avo:tailwindcss:install"
        desc "Add Tailwindcss to your Avo project."

        def create_files
          unless tailwindcss_installed?
            system "./bin/bundle add tailwindcss-rails"
            system "./bin/rails tailwindcss:install"
          end

          unless Rails.root.join("app", "assets", "stylesheets", "avo.tailwind.css").exist?
            say "Add default app/assets/stylesheets/avo.tailwind.css"
            copy_file template_path("avo.tailwind.css"), "app/assets/stylesheets/avo.tailwind.css"
          end

          if Rails.root.join("Procfile.dev").exist?
            append_to_file "Procfile.dev", "avo_css: yarn avo:tailwindcss --watch\n"
          else
            say "Add default Procfile.dev"
            copy_file template_path("Procfile.dev"), "Procfile.dev"

            say "Ensure foreman is installed"
            run "gem install foreman"
          end

          # Ensure that the _pre_head.html.erb template is available
          unless Rails.root.join("app", "views", "avo", "partials", "_pre_head.html.erb").exist?
            say "Ejecting the _pre_head.html.erb partial"
            Rails::Generators.invoke("avo:eject", [":pre_head", "--skip-avo-version"], {destination_root: Rails.root})
          end

          say "Adding the CSS asset to the partial"
          prepend_to_file Rails.root.join("app", "views", "avo", "partials", "_pre_head.html.erb"), "<%= stylesheet_link_tag \"avo.tailwind.css\", media: \"all\" %>"

          tailwind_script = setup_tailwind_script
          say "Ensure you have the following script in your package.json file.", :yellow
          say %("scripts": { "avo:tailwindcss": "#{tailwind_script}" --minify }), :green
        end

        no_tasks do
          def setup_tailwind_script
            tailwind_config_path = tailwindcss_config_path()
            tailwind_script = "tailwindcss -i ./app/assets/stylesheets/avo.tailwind.css -o ./app/assets/builds/avo.tailwind.css"
            tailwind_script += " -c #{tailwind_config_path}" if tailwind_config_path
            tailwind_script
          end  

          def template_path(filename)
            Pathname.new(__dir__).join("..", "templates", "tailwindcss", filename).to_s
          end

          def tailwindcss_installed?
            Rails.root.join("config", "tailwind.config.js").exist? || Rails.root.join("tailwind.config.js").exist?
          end

          def tailwindcss_config_path
            if Rails.root.join("config", "tailwind.config.js").exist?
              "./config/tailwind.config.js"
            end
          end
        end
      end
    end
  end
end
