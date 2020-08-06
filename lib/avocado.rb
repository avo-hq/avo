require_relative 'avocado/configuration'
require_relative 'avocado/app/fields/field'

module Avocado
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

require_relative 'avocado/engine' if defined?(Rails)
