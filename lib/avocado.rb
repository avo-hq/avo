require "avocado/engine"
require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.push_dir(Pathname.new(File.join(__dir__, "..", 'src')))
# loader.push_dir(Pathname.new(File.join(__dir__, '..', "app", 'resources')))
# loader.collapse(__dir__, "..", 'src', 'tools', '**')
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
  end
end
