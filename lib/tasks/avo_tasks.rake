require "open3"

desc "Updates all Avo gems; set AVO_UPDATE_PUSH=1 to commit Gemfile.lock and push."
task "avo:update" => :environment do
  push = ENV["AVO_UPDATE_PUSH"] == "1"
  lockfile = Bundler.default_lockfile.to_s

  if push
    status, result = Open3.capture2("git", "status", "--porcelain", "--untracked-files=all")
    abort "[Avo->] AVO_UPDATE_PUSH requires a Git repository." unless result.success?
    abort "[Avo->] AVO_UPDATE_PUSH requires a clean Git working tree." unless status.empty?
    unless system("git", "rev-parse", "--verify", "@{upstream}", out: File::NULL, err: File::NULL)
      abort "[Avo->] AVO_UPDATE_PUSH requires a branch with an existing upstream."
    end
  end

  # Start with avo core (it doesn't register itself as a plugin), then resolve
  # every registered plugin to its real gem name. Plugins register under
  # nicknames (e.g. `avo-rhino_field` registers as `:rhino`), so we ask each
  # plugin for the gem it actually ships in instead of trusting the nickname.
  gems = (["avo"] + Avo.plugin_manager.plugins.filter_map(&:gem_name)).uniq.sort

  if gems.empty?
    puts "[Avo->] No Avo gems found in the bundle."
    next
  end

  # `--conservative` keeps bundler from bumping shared dependencies that aren't
  # Avo gems themselves, so we only update the gems we explicitly list.
  cmd = ["bundle", "update", "--conservative", *gems].join(" ")
  puts "[Avo->] Running `#{cmd}`"
  # Restore the pre-Bundler env so the nested `bundle update` runs against the
  # app's Gemfile with a clean environment. Without this it inherits the parent
  # `bundle exec` settings (BUNDLE_GEMFILE, BUNDLE_FROZEN/--deployment, RUBYOPT),
  # which can make the update silently refuse. Exported credentials survive
  # because they're part of the original env Bundler snapshotted at boot.
  abort "[Avo->] Gem update failed; nothing committed or pushed." unless Bundler.with_original_env { system cmd }

  if push
    abort "[Avo->] Could not stage #{lockfile}; nothing pushed." unless system("git", "add", "--", lockfile)
    _, result = Open3.capture2("git", "diff", "--cached", "--quiet", "--", lockfile)
    if result.success?
      puts "[Avo->] Gemfile.lock is unchanged; nothing committed or pushed."
      next
    end
    abort "[Avo->] Could not inspect Gemfile.lock; nothing pushed." unless result.exitstatus == 1
    unless system("git", "commit", "--only", "-m", "Update Avo gems", "--", lockfile)
      abort "[Avo->] Commit failed; nothing pushed."
    end
    abort "[Avo->] Push failed; the update commit is available locally." unless system("git", "push")
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
