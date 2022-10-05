require 'rails/generators/active_record/model/model_generator'

module Rails
  module Generators
    class AvoResourceGenerator < ActiveRecord::Generators::ModelGenerator
      source_root "#{base_root}/active_record/model/templates"
      hide!

      def invoke_avo_command
        invoke "avo:resource", [name], {}
      end
    end
  end
end
