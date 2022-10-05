require 'rails/generators/active_record/model/model_generator'

module Rails
  module Generators
    class AvoResourceGenerator < ActiveRecord::Generators::ModelGenerator
      source_root "#{base_root}/active_record/model/templates"
      hide!

      # TODO: We can remove this now
      # def initialize(name, *options, **kwargs)
      #   puts ["1->", options, kwargs].inspect
      #   super(name, *options, **kwargs)
      #   puts ["2->"].inspect
      # end

      def invoke_avo_command
        # TODO: figure out the `name` and options from the command instance
        # puts ["name, args->", attributes, '|', name, args, options, self.methods].inspect
        # invoke "avo:resource", name, *options
      end
    end
  end
end
