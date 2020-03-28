require "avocado/engine"
# require "tools"

loader = Zeitwerk::Loader.for_gem
loader.push_dir(Pathname.new(File.join(__dir__, "..", 'src')))
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
  end
end
