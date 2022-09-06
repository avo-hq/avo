# Use the user provided asset or use the default
ASSET_FILE = ARGV[0] || "app/assets/builds/avo.tailwind.css"
# Se the tailwindcss-rails package name
TAILWINDCSS_RAILS = "tailwindcss-rails"

# Check if tailwindcss-rails is being used
if Gem.loaded_specs.key? TAILWINDCSS_RAILS
  # Get the path
  GEM_PATH = Gem.loaded_specs[TAILWINDCSS_RAILS].full_gem_path
  # Compose the compile command
  AVO_TAILWIND_COMPILE_COMMAND = "#{RbConfig.ruby} #{Pathname.new(GEM_PATH)}/exe/tailwindcss -i '#{Rails.root.join("app/assets/stylesheets/avo.css")}' -o '#{Rails.root.join(ASSET_FILE)}' -c '#{Rails.root.join("config/tailwind.config.js")}' --minify"

  namespace "avo:tailwindcss" do
    desc "Build your Tailwind CSS"
    task :build do
      system(AVO_TAILWIND_COMPILE_COMMAND, exception: true)
    end

    desc "Watch and build your Tailwind CSS on file changes"
    task :watch do
      system "#{AVO_TAILWIND_COMPILE_COMMAND} -w"
    end
  end
end
