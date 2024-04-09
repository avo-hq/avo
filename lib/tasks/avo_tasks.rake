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

desc "Installs Avo assets and bundles them for when you want to use the GitHub repo in your app"
task "avo:build-assets" do
  spec = get_gem_spec "avo"
  # Uncomment to enable only when the source is github.com
  # enabled = spec.source.to_s.include?('https://github.com/avo-hq/avo')
  enabled = true

  if enabled
    puts "Starting avo:build-assets"
    path = spec.full_gem_path

    Dir.chdir(path) do
      system "yarn"
      system "bundle exec rails avo:sym_link"
      system "yarn prod:build"
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

desc "Finds all Avo gems and outputs theyr paths"
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

desc "Symlinks all Avo gems to tmp/avo/packages"
task "avo:sym_link" do
  base_path = Rails.root.join("tmp", "avo").to_s.gsub("/spec/dummy", "")
  packages_path = "#{base_path}/packages"
  if Dir.exist?(packages_path)
    `rm -rf #{packages_path}/*`
  else
    `mkdir -p #{packages_path}`
    `touch #{packages_path}/.keep`
  end

  ["avo-advanced", "avo-pro", "avo-dynamic_filters", "avo-dashboards", "avo-menu", "avo-audits"].each do |gem|
    path = `bundle show #{gem} 2> /dev/null`.chomp

    # If path is emty we check if package is defined outside of root (on release process it is)
    if path.empty?
      next if !Dir.exist?("../#{gem}")

      path = File.expand_path("../#{gem}")
    end

    puts "[Avo->] Linking #{gem} to #{path}"
    symlink_path path, "#{packages_path}/#{gem}"
  end

  builds_css_path = Avo::Engine.root.join("app", "assets", "builds", "avo.base.css")
  public_css_path = Avo::Engine.root.join("public", "avo-assets", "avo.base.css")

  base_css_path = if File.exist?(builds_css_path.to_s)
    builds_css_path
  elsif File.exist?(public_css_path.to_s)
    public_css_path
  else
    raise "[Avo->] Failed to find avo.base.css."
  end

  dest_css_path = "#{base_path}/avo.base.css"
  remove_file_if_exists dest_css_path

  puts "[Avo->] Linking avo.base.css to #{base_css_path}"
  symlink_path base_css_path, dest_css_path

  base_preset_path = Avo::Engine.root.join("tailwind.preset.js")
  dest_preset_path = "#{base_path}/tailwind.preset.js"
  remove_file_if_exists dest_preset_path

  puts "[Avo->] Linking tailwind.preset.js to #{base_preset_path}"
  symlink_path base_preset_path, dest_preset_path
end

def remove_file_if_exists(path)
  `rm #{path}` if File.exist?(path) || File.symlink?(path)
end

def symlink_path(from, to)
  remove_file_if_exists to

  `ln -s #{from} #{to}`
end

desc "Installs yarn dependencies for Avo"
task "avo:yarn_install" do
  # tailwind.preset.js needs this dependencies in order to be required
  puts "[Avo->] Adding yarn dependencies"
  `yarn add tailwindcss @tailwindcss/forms @tailwindcss/typography --cwd #{Avo::Engine.root}`
end
