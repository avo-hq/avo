# desc 'Explaining what the task does'
# task :avo do
#   # Task goes here
# end

desc 'Installs Avo assets and bundles them for when you want to use the GitHub repo in your app'
task 'avo:install' do
  enabled = true

  if enabled
    puts "Starting avo:install"
    path = locate_gem 'avo'

    Dir.chdir(path) do
      system 'yarn'
      system 'yarn prod:build'
    end

    puts "Done"
  else
    puts "Not starting avo:install"
  end
end

# From
# https://stackoverflow.com/questions/9322078/programmatically-determine-gems-path-using-bundler
def locate_gem(name)
  spec = Bundler.load.specs.find{|s| s.name == name }
  raise GemNotFound, "Could not find gem '#{name}' in the current bundle." unless spec
  if spec.name == 'bundler'
    return File.expand_path('../../../', __FILE__)
  end
  spec.full_gem_path
end
