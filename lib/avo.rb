require_relative 'avo/configuration'
require_relative 'avo/app/fields/field'

module Avo
  ROOT_PATH = Pathname.new(File.join(__dir__, '..'))

  class << self
    def webpacker
      @webpacker ||= ::Webpacker::Instance.new(
        root_path: ROOT_PATH,
        config_path: ROOT_PATH.join('config/webpacker.yml')
      )
    end
  end
end

require_relative 'avo/engine' if defined?(Rails)
