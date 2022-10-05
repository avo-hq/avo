require 'rails/generators/active_record/model/model_generator'

module Rails
  module Generators
    class AvoResourceGenerator < ActiveRecord::Generators::ModelGenerator
      source_root "#{base_root}/active_record/model/templates"
      hide!

      def initialize(name, *options)
        super(name, *options)
        invoke "avo:resource", name, *options
      end
    end
  end
end
