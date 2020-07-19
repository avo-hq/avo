require 'avocado/engine'
require 'zeitwerk'
require_relative 'avocado/configuration'

loader = Zeitwerk::Loader.for_gem
loader.push_dir(Pathname.new(File.join(__dir__, 'avocado')))
loader.setup

module Avocado
  require_relative 'avocado/app/tools_manager'
  require_relative 'avocado/app/filter'
  require_relative 'avocado/app/filters/select_filter'
  require_relative 'avocado/app/filters/boolean_filter'
  require_relative 'avocado/app/resource'
  require_relative 'avocado/app/tool'
  require_relative 'avocado/app/fields/field'

  ROOT_PATH = Pathname.new(File.join(__dir__, '..'))

  class << self
    def webpacker
      @webpacker ||= ::Webpacker::Instance.new(
        root_path: ROOT_PATH,
        config_path: ROOT_PATH.join('config/webpacker.yml')
      )
    end

    def root_path
      '/avocado'
    end
  end
end
