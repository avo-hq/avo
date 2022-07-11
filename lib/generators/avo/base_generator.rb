require "rails/generators"

module Generators
  module Avo
    class BaseGenerator < ::Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      hide!

      def initialize(*args)
        super(*args)
        invoke "avo:version", *args
      end
    end
  end
end
