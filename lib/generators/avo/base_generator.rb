require "rails/generators"

module Generators
  module Avo
    class BaseGenerator < ::Rails::Generators::Base
      def initialize(*args)
        super(*args)
        invoke "avo:version", *args
      end
    end
  end
end
