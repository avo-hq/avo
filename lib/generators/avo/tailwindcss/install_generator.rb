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
            say "Installing Tailwindcss"
            system "./bin/bundle add tailwindcss-rails"
            system "./bin/rails tailwindcss:install"
          end

          unless (path = Rails.root.join("config", "avo", "tailwind.config.js")).exist?
            say "Generating the Avo config file."
            copy_file template_path("tailwind.config.js"), path
          end

          unless (path = Rails.root.join("app", "assets", "stylesheets", "avo", "tailwindcss")).exist?
            say "Generating the tailwindcss directory."
            directory ::Avo::Engine.root.join("app", "assets", "stylesheets", "css", "tailwindcss"), path
          end


          unless (path = Rails.root.join("app", "assets", "stylesheets", "avo" ,"tailwind.css")).exist?
            say "Add default tailwind.css"
            copy_file template_path("avo.tailwind.css"), path
          end

          script_name = "avo:tailwind:css"
          if Rails.root.join("Procfile.dev").exist?
            say "Add #{cmd = "avo_css: yarn #{script_name} --watch"} to Procfile.dev"
            append_to_file "Procfile.dev", "#{cmd}\n"
          else
            say "Add default Procfile.dev"
            copy_file template_path("Procfile.dev"), "Procfile.dev"

            say "Ensure foreman is installed"
            run "gem install foreman"
          end

          script_command = "tailwindcss -i ./app/assets/stylesheets/avo/tailwind.css -o ./app/assets/builds/avo.tailwind.css -c ./config/avo/tailwind.config.js --minify"
          pretty_script_command = "\"#{script_name}\": \"#{script_command}\""

          if (path = Rails.root.join("package.json")).exist?
            say "Add #{pretty_script_command} to package.json"
            json_data = JSON.parse(File.read(path))
            json_data["scripts"] ||= {}
            json_data["scripts"][script_name] = script_command

            File.open(path, 'w') do |file|
              file.write(JSON.pretty_generate(json_data) + "\n")
            end
          else
            say "package.json not found.", :yellow
            say "Ensure you have the following script in your package.json file.", :yellow
            say "\"scripts\": {\n" \
              "  #{pretty_script_command}\n" \
            "}", :green
          end

          rake_enhance = <<~RUBY

            # When running `rake assets:precompile` this is the order of events:
            # 1 - Task `avo:yarn_install`
            # 2 - Task `avo:sym_link`
            # 3 - Cmd  `yarn avo:tailwind:css`
            # 4 - Task `assets:precompile`
            Rake::Task["assets:precompile"].enhance(["avo:sym_link"])
            Rake::Task["avo:sym_link"].enhance(["avo:yarn_install"])
            Rake::Task["avo:sym_link"].enhance do
              `yarn avo:tailwind:css`
            end

          RUBY

          if (path = Rails.root.join("Rakefile")).exist?
            say "Add #{rake_enhance.strip} to Rakefile"
            append_to_file path, rake_enhance
          else
            say "Rakefile not found.", :yellow
            say "Ensure you have the following code in your Rakefile file.", :yellow
            say rake_enhance, :green
          end

          say "Make sure you run \"bundle exec rake avo:sym_link\" and \"bundle exec rake avo:yarn_install\" before compiling the assets with the \"#{script_name}\" task.", :green
          if (path = Rails.root.join("bin", "dev")).exist?
            lines = File.read(path).lines

            # Insert the task after the shebang line (the first line)
            shebang = lines.first
            lines[0] = "#{shebang}\nbundle exec rake avo:sym_link\nbundle exec rake avo:yarn_install\n"


            File.write(path, lines.join)
          end
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
