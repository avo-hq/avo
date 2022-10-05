require 'rails/generators/active_record/model/model_generator'

module Rails
  module Generators
    class AvoResourceGenerator < ::Rails::Generators::Base
      def invoke_avo_command
        invoke "avo:resource", @args, {from_model_generator: true}
      end
    end
  end
end
