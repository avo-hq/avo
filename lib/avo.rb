require_relative 'avo/configuration'
require_relative 'avo/version'
require_relative 'avo/app'

# require_relative 'avo/fields/base_field'

# require_relative 'avo/action'

# require_relative 'avo/filters/base_filter'
# require_relative 'avo/filters/boolean_filter'
# require_relative 'avo/filters/select_filter'

# require_relative 'avo/fields_loader'
# require_relative 'avo/actions_loader'
# require_relative 'avo/resource'

# require_relative 'avo/licensing/license_manager'


require_relative 'avo/engine' if defined?(Rails)
require 'listen'

# require "zeitwerk"
# loader = Zeitwerk::Loader.for_gem
# loader.push_dir(__dir__)
# # loader.push_dir("#{__dir__}/avo")

# # loader.push_dir(Avo::Engine.root.join('lib', 'avo'))
# loader.enable_reloading
# # loader.log! # ready!
# # puts __dir__.inspect
# Listen.to(__dir__) {
#   puts 'listened----->>>>>'.inspect
#   loader.reload
#   loader.eager_load

#   Avo::App.init_resources
#   Avo::App.boot
#   puts ['Avo::App.get_resources.count->', Avo::App.get_resources.count].inspect

#   # Dir[Rails.root.join('app', 'avo', 'resources', '*.rb')].each {|file| require file }
#   puts 'booted----->>>>>'.inspect

#   # ::Avo::App.init_fields
#   # ::Avo::App.init
# }.start
# # Zeitwerk::Loader.eager_load_all
# # Listen.to("#{__dir__}/avo") {
# #   puts 'listened app----->>>>>'.inspect
# #   loader.reload
# # }.start
# loader.setup # ready!

module Avo
  ROOT_PATH = Pathname.new(File.join(__dir__, '..'))
  IN_DEVELOPMENT = ENV['AVO_IN_DEVELOPMENT'] == '1'
  PACKED = !IN_DEVELOPMENT
  # PACKED = true

  class << self
    def webpacker
      @webpacker ||= ::Webpacker::Instance.new(
        root_path: ROOT_PATH,
        config_path: ROOT_PATH.join('config/webpacker.yml')
      )
    end
  end
end

# loader.eager_load # optionally
