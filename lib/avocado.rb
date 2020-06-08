require "avocado/engine"
require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.push_dir(Pathname.new(File.join(__dir__, 'avocado')))
loader.setup

module Avocado
  ROOT_PATH = Pathname.new(File.join(__dir__, ".."))

  class << self
    def webpacker
      @webpacker ||= ::Webpacker::Instance.new(
        root_path: ROOT_PATH,
        config_path: ROOT_PATH.join("config/webpacker.yml")
      )
    end

    def root_path
      '/avocado'
    end

    def config
      {
        timezone: 'Europe/Bucharest',
        per_page: 24,
        per_page_steps: [24, 48, 72],
        via_per_page: 8,
      }
    end
  end
end
