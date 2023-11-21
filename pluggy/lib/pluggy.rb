require "zeitwerk"
require_relative "pluggy/railtie"

loader = Zeitwerk::Loader.for_gem
loader.setup

module Pluggy
end

# loader.eager_load
