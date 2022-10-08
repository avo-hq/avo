# frozen_string_literal: true

module Avo
  module Concerns
    module PreloadsSubclasses
      extend ActiveSupport::Concern

      included do
        class_attribute :subclass_directory_name
      end

      class_methods do
        def descendants
          unless Rails.application.config.eager_load
            subclass_files.each do |component_path|
              component_path.delete_suffix('.rb').camelize.constantize
            rescue NameError
              load subclass_directory_path.join(component_path).to_s
            end
          end

          super
        end

        def subclass_directory_path
          Rails.root.join('app', 'avo', subclass_directory_name)
        end

        def subclass_files
          Dir['**/*.rb', base: subclass_directory_path]
        end
      end
    end
  end
end
