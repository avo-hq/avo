require "rails/generators"

module Generators
  module Avo
    class BaseGenerator < ::Rails::Generators::Base
      hide!

      def initialize(*args)
        super(*args)

        # Don't output the version if requested so
        unless args.include?(["--skip-avo-version"])
          invoke "avo:version", *args
        end
      end
    end
  end
end
