require "rails/generators"

module Generators
  module Avo
    class NamedBaseGenerator < ::Rails::Generators::NamedBase
      def initialize(args, *options)
        super(args, *options)
        invoke "avo:version"
      end
    end
  end
end
