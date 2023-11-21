$:.push File.expand_path("lib", __dir__)

require "pluggy/version"

Gem::Specification.new do |s|
  s.name = "pluggy"
  s.version = Pluggy::VERSION
  s.summary = "Multiple plugin demo."
  s.description = "Multiple plugin demo."
  s.authors = ["Adrian Marin"]
  s.email = "adrian@adrianthedev.com"
  s.files = ["lib/pluggy.rb"]
  s.homepage = "https://avohq.io"
  s.license = "MIT"
end
