require "rails/generators"

module Generators
  module Avo
    class NamedBaseGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      hide!

      def initialize(name, *options)
        super(name, *options)
        invoke "avo:version", name, *options
      end
    end
  end
end
