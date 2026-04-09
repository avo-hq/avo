desc "Runs the update command for all Avo gems."
task "avo:update" => :environment do
  plugins = Avo.plugin_manager.plugins
    .map { |plugin| plugin.name.to_s }
    .uniq
    .sort

  cmd = ["bundle", "update", *plugins].join(" ")
  puts "[Avo->] Running `#{cmd}`"
  system cmd
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

desc "Symlinks all Avo gems to tmp/avo/packages"
task "avo:sym_link" do
  puts "Running avo:sym_link"
  base_path = Rails.root.join("tmp", "avo", "build-assets").to_s.gsub("/spec/dummy", "")

  remove_directory_if_exists base_path

  packages_path = "#{base_path}/packages"

  if Dir.exist?(packages_path)
    `rm -rf #{packages_path}/*`
  else
    `mkdir -p #{packages_path}`
    `touch #{packages_path}/.keep`
  end

  gem_paths = `bundle list --paths 2>/dev/null`.split("\n")
  ["avo-advanced", "avo-pro", "avo-dynamic_filters", "avo-dashboards", "avo-menu", "avo-kanban", "avo-forms"].each do |gem|
    path = gem_paths.find { |gem_path| gem_path.include?("/#{gem}-") }

    # If path is nil we check if package is defined outside of root (on release process it is)
    if path.nil?
      next if !Dir.exist?("../#{gem}")

      path = File.expand_path("../#{gem}")
    end

    puts "[Avo->] Linking #{gem} to #{path}"
    symlink_path path, "#{packages_path}/#{gem}"
  end

  application_css_path = Avo::Engine.root.join("app", "assets", "stylesheets", "application.css")
  raise "[Avo->] Failed to find #{application_css_path}." unless File.exist?(application_css_path.to_s)

  dest_css_path = "#{base_path}/application.css"
  remove_file_if_exists dest_css_path

  puts "[Avo->] Linking application.css to #{application_css_path}"
  symlink_path application_css_path, dest_css_path
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

desc "Build Avo custom Tailwind CSS (requires tailwindcss-ruby gem; outputs app/assets/builds/avo/application.css)"
task "avo:tailwindcss:build" => :environment do
  unless Avo::TailwindBuilder.enabled?
    puts "[Avo->] tailwindcss integration disabled or tailwindcss-ruby not found; skipping avo:tailwindcss:build"
    next
  end

  puts "[Avo->] Building Avo Tailwind CSS extension (avo/application)..."
  unless Avo::TailwindBuilder.build
    abort "[Avo->] avo:tailwindcss:build failed"
  end
end

desc "Watch Avo custom Tailwind CSS (requires tailwindcss-ruby gem; outputs app/assets/builds/avo/application.css)"
task "avo:tailwindcss:watch" => :environment do
  unless Avo::TailwindBuilder.enabled?
    puts "[Avo->] tailwindcss integration disabled or tailwindcss-ruby not found; skipping avo:tailwindcss:watch"
    next
  end

  puts "[Avo->] Watching Avo Tailwind CSS extension (avo/application)..."
  unless Avo::TailwindBuilder.watch
    abort "[Avo->] avo:tailwindcss:watch failed"
  end
end

desc "Verify Inter font files referenced by Avo fonts.css"
task "avo:fonts:verify" do
  require "digest"

  fonts_css_path = Avo::Engine.root.join("app", "assets", "stylesheets", "css", "fonts.css")
  fonts_dir = Avo::Engine.root.join("app", "assets", "images", "avo", "fonts")

  unless File.exist?(fonts_css_path)
    abort "[Avo->] Missing fonts.css at #{fonts_css_path}"
  end

  references = File.read(fonts_css_path)
    .scan(/url\('fonts\/([^'?#)]+)/)
    .flatten
    .uniq
    .sort

  missing = references.reject { |name| File.exist?(fonts_dir.join(name)) }
  if missing.any?
    abort "[Avo->] Missing font assets in #{fonts_dir}:\n- #{missing.join("\n- ")}"
  end

  # Guard against placeholder/copied files by flagging duplicate content
  # for weight-specific legacy formats.
  suspicious_groups = [
    %w[
      inter-v7-latin-regular.eot
      inter-v7-latin-500.eot
      inter-v7-latin-600.eot
      inter-v7-latin-700.eot
    ],
    %w[
      inter-v7-latin-regular.svg
      inter-v7-latin-500.svg
      inter-v7-latin-600.svg
      inter-v7-latin-700.svg
    ],
  ]

  duplicate_findings = []
  suspicious_groups.each do |group|
    existing = group.select { |name| File.exist?(fonts_dir.join(name)) }
    next if existing.size < 2

    checksums = existing.group_by do |name|
      Digest::SHA256.file(fonts_dir.join(name)).hexdigest
    end

    checksums.each_value do |matches|
      duplicate_findings << matches if matches.size > 1
    end
  end

  if duplicate_findings.any?
    details = duplicate_findings.map { |group| "- #{group.join(', ')}" }.join("\n")
    abort "[Avo->] Suspicious duplicate font files detected (possible placeholders):\n#{details}"
  end

  puts "[Avo->] Fonts verification passed (#{references.size} referenced files present)."
end

desc "Sync Inter font files from source dir into app/assets/images/avo/fonts, then verify"
task "avo:fonts:sync", [:source_dir] do |_t, args|
  require "fileutils"

  source_dir = args[:source_dir]
  if source_dir.blank?
    abort "[Avo->] Usage: bin/rails \"avo:fonts:sync[/absolute/or/relative/source_dir]\""
  end

  source_path = Pathname.new(source_dir)
  source_path = Avo::Engine.root.join(source_dir) if source_path.relative?
  source_path = source_path.expand_path

  unless source_path.directory?
    abort "[Avo->] Source directory not found: #{source_path}"
  end

  fonts_css_path = Avo::Engine.root.join("app", "assets", "stylesheets", "css", "fonts.css")
  target_dir = Avo::Engine.root.join("app", "assets", "images", "avo", "fonts")
  FileUtils.mkdir_p(target_dir)

  references = File.read(fonts_css_path)
    .scan(/url\('fonts\/([^'?#)]+)/)
    .flatten
    .uniq

  missing_in_source = []
  references.each do |name|
    source_file = source_path.join(name)
    if source_file.exist?
      FileUtils.cp(source_file, target_dir.join(name))
    else
      missing_in_source << name
    end
  end

  if missing_in_source.any?
    abort "[Avo->] Missing files in source directory #{source_path}:\n- #{missing_in_source.join("\n- ")}"
  end

  Rake::Task["avo:fonts:verify"].invoke
end
