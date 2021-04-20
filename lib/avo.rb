require "zeitwerk"
require_relative "avo/version"
require_relative "avo/engine" if defined?(Rails)

loader = Zeitwerk::Loader.for_gem
loader.setup

module Avo
  ROOT_PATH = Pathname.new(File.join(__dir__, ".."))
  IN_DEVELOPMENT = ENV["AVO_IN_DEVELOPMENT"] == "1"
  PACKED = !IN_DEVELOPMENT

  class LicenseVerificationTemperedError < StandardError; end

  class LicenseInvalidError < StandardError; end

  class << self
    def webpacker
      @webpacker ||= ::Webpacker::Instance.new(
        root_path: ROOT_PATH,
        config_path: ROOT_PATH.join("config/webpacker.yml")
      )
    end

    def manifester
      @manifester ||= ::Manifester::Instance.new(
        root_path: ROOT_PATH,
        public_output_dir: "avo-packs",
        cache_manifest: Rails.env.production?,
        fallback_to_webpacker: -> { Avo::IN_DEVELOPMENT }
      )
    end
  end
end

loader.eager_load
