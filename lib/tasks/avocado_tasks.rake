# desc 'Explaining what the task does'
# task :avocado do
#   # Task goes here
# end

def ensure_log_goes_to_stdout
  old_logger = Webpacker.logger
  Webpacker.logger = ActiveSupport::Logger.new(STDOUT)
  yield
ensure
  Webpacker.logger = old_logger
end


namespace :avocado do
  namespace :webpacker do
    desc 'Install deps with yarn'
    task :yarn_install do
      Dir.chdir(File.join(__dir__, '../..')) do
        system 'yarn install --no-progress --production'
      end
    end

    desc 'Compile JavaScript packs using webpack for production with digests'
    task compile: [:yarn_install, :environment] do
      Webpacker.with_node_env('production') do
        ensure_log_goes_to_stdout do
          if Avocado.webpacker.commands.compile
            # Successful compilation!
          else
            # Failed compilation
            exit!
          end
        end
      end
    end
  end
end

def yarn_install_available?
  rails_major = Rails::VERSION::MAJOR
  rails_minor = Rails::VERSION::MINOR

  rails_major > 5 || (rails_major == 5 && rails_minor >= 1)
end

def enhance_assets_precompile
  # yarn:install was added in Rails 5.1
  deps = yarn_install_available? ? [] : ['avocado:webpacker:yarn_install']
  # Rake::Task['assets:precompile'].enhance(deps) do
  #   Rake::Task['avocado:webpacker:compile'].invoke
  # end
end

# Compile packs after we've compiled all other assets during precompilation
skip_webpacker_precompile = %w(no false n f).include?(ENV['WEBPACKER_PRECOMPILE'])

unless skip_webpacker_precompile
  if Rake::Task.task_defined?('assets:precompile')
    enhance_assets_precompile
  else
    Rake::Task.define_task('assets:precompile' => 'avocado:webpacker:compile')
  end
end
