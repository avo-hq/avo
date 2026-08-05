require "rails/generators"

module Generators
  module Avo
    class NamedBaseGenerator < ::Rails::Generators::NamedBase
      hide!

      def initialize(name, *options)
        super
        invoke "avo:version", name, *options
      end
    end
  end
end
