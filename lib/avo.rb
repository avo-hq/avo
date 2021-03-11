require_relative 'avo/configuration'
require_relative 'avo/version'

require_relative 'avo/fields/field'

require_relative 'avo/action'

require_relative 'avo/filter'
require_relative 'avo/filters/boolean_filter'
require_relative 'avo/filters/select_filter'

require_relative 'avo/fields_loader'
require_relative 'avo/actions_loader'
# require_relative 'avo/fields_loader_helper'
require_relative 'avo/resource'

require_relative 'avo/licensing/license_manager'

module Avo
  ROOT_PATH = Pathname.new(File.join(__dir__, '..'))
  IN_DEVELOPMENT = ENV['AVO_IN_DEVELOPMENT'] == '1'
  PACKED = !IN_DEVELOPMENT

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
