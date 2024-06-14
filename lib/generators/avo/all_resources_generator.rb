require_relative "base_generator"

module Generators
  module Avo
    class AllResourcesGenerator < BaseGenerator
      namespace "avo:all_resources"

      def task
        # Rails.application.eager_load!
        # get all models
        models = fetch_models

        models
          .reject do |model|
            model.in?(%w[ApplicationRecord])
          end
          .each do |model|
            begin
              invoke "avo:resource", [model.underscore], {}
            rescue => e
              puts "Error: #{e.message}"
            end
          end
      end

      no_tasks do
        def fetch_models
          model_files = Dir[Rails.root.join('app/models/**/*.rb')]
          model_files.map do |file|
            model_name = file.sub(Rails.root.join('app/models/').to_s, '').sub('.rb', '')
            model_name.camelize.constantize
            model_name.camelize
          rescue NameError
          nil
          end.compact
        end
      end
    end
  end
end
