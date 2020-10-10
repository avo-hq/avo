require_relative 'avo/configuration'
require_relative 'avo/version'

require_relative 'avo/app/fields/field'

require_relative 'avo/app/action'

require_relative 'avo/app/filter'
require_relative 'avo/app/filters/boolean_filter'
require_relative 'avo/app/filters/select_filter'

require_relative 'avo/app/resource'

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
