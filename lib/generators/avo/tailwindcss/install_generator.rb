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
            append_to_file "Procfile.dev", "avo_css: bin/rails avo:tailwindcss:watch\n"
          else
            say "Add default Procfile.dev"
            copy_file template_path("Procfile.dev"), "Procfile.dev"

            say "Ensure foreman is installed"
            run "gem install foreman"
          end

          say "Ejecting the _head.html.erb partial"
          Rails::Generators.invoke("avo:eject", [":head", "--no-avo-version"], {destination_root: Rails.root})

          say "Adding the CSS asset to the partial"
          prepend_to_file Rails.root.join("app", "views", "avo", "partials", "_head.html.erb"), "<%= stylesheet_link_tag \"avo.tailwind.css\", media: \"all\" %>"
        end

        no_tasks do
          def template_path(filename)
            Pathname.new(__dir__).join("..", "templates", "tailwindcss", filename).to_s
          end

          def tailwindcss_installed?
            Rails.root.join("config", "tailwind.config.js").exist? || Rails.root.join("tailwind.config.js").exist?
          end
        end
      end
    end
  end
end
