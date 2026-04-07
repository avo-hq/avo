desc "Runs the update command for all Avo gems."
task "avo:update" do
  gems = Gem::Specification.map { |gem| gem.name }

  @license ||= if gems.include?("avo-advanced")
    system "bundle update avo avo-advanced"
  elsif gems.include?("avo-pro")
    system "bundle update avo avo-pro"
  elsif gems.include?("avo")
    system "bundle update avo"
  end
end

desc "Builds Avo (just assets for now)"
task "avo:build" do
  Rake::Task["avo:build-assets"].invoke
end

desc "Installs Avo assets and bundles them for when you want to use the GitHub repo in your app"
task "avo:build-assets" do
  puts "Building Avo assets"
  spec = get_gem_spec "avo"
  # Uncomment to enable only when the source is github.com
  # enabled = spec.source.to_s.include?('https://github.com/avo-hq/avo')
  enabled = true

  if enabled
    puts "Starting avo:build-assets"
    path = spec.full_gem_path

    Dir.chdir(path) do
      puts "Running `yarn install`"
      system "yarn"

      puts "Running `yarn build`"
      system "yarn build"
    end

    puts "Done"
  else
    puts "Not starting avo:build-assets"
  end
end

# From
# https://stackoverflow.com/questions/9322078/programmatically-determine-gems-path-using-bundler
def get_gem_spec(name)
  spec = Bundler.load.specs.find { |s| s.name == name }
  raise GemNotFound, "Could not find gem '#{name}' in the current bundle." unless spec
  if spec.name == "bundler"
    return File.expand_path("../../../", __FILE__)
  end

  spec
end

desc "Finds all Avo gems and outputs their paths"
task "avo:gem_paths" do
  config = YAML.load_file("../support/gems.yml")

  existing_gems = config["gems"].keys
    .map do |gem|
      path = `bundle show #{gem} 2> /dev/null`.chomp

      unless path.empty?
        "#{gem}:#{path}"
      end
    end
    .reject(&:nil?)
  result = existing_gems.join(",")

  # Outputs a CSV "hash-like" string in this format
  #
  # GEM_NAME:GEM_PATH,SECOND_GEM_NAME:SECOND_GEM_PATH
  # avo:/Users/adrian/work/avocado/avo-3,avo_filters:/Users/adrian/work/avocado/advanced/avo_filters
  puts result
end

def remove_file_if_exists(path)
  `rm #{path}` if File.exist?(path) || File.symlink?(path)
end

def remove_directory_if_exists(path)
  `rm -rf #{path}` if Dir.exist?(path) || File.symlink?(path)
end

def symlink_path(from, to)
  remove_file_if_exists to

  `ln -s #{from} #{to}`
end

desc "Installs yarn dependencies for Avo"
task "avo:yarn_install" do
  # tailwind.preset.js needs this dependencies in order to be required
  # Ensure that versions remain updated and synchronized with those specified in package.json.
  puts "[Avo->] Adding yarn dependencies"
  `yarn add tailwindcss@^4.0.0 @tailwindcss/typography@^0.5.16 @tailwindcss/container-queries@^0.1.1 --cwd #{Avo::Engine.root}`
end

desc "Build Avo custom Tailwind CSS (requires tailwindcss-ruby gem; outputs app/assets/builds/avo.tailwind.css)"
task "avo:tailwindcss:build" => :environment do
  unless Avo::TailwindBuilder.tailwindcss_available?
    puts "[Avo->] tailwindcss-ruby not found; skipping avo:tailwindcss:build"
    next
  end

  puts "[Avo->] Building Avo Tailwind CSS extension (avo.tailwind)..."
  unless Avo::TailwindBuilder.build
    abort "[Avo->] avo:tailwindcss:build failed"
  end
end
