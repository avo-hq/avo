module Avo
  class DynamicRouter
    def self.eager_load(entity)
      paths = Avo::ENTITIES.fetch entity

      return unless paths.present?

      pathname = Rails.root.join(*paths)
      if pathname.directory?
        Rails.autoloaders.main.eager_load_dir(pathname.to_s)
      end
    end

    def self.routes
      Avo::Engine.routes.draw do
        scope "resources", as: "resources" do
          # Check if the user chose to manually register the resource files.
          # If so, eager_load the resources dir.
          if Avo.configuration.resources.nil?
            Avo::DynamicRouter.eager_load(:resources) unless Rails.application.config.eager_load
          end

          Avo::Resources::ResourceManager.fetch_resources
            .select do |resource|
              resource != :BaseResource
            end
            .select do |resource|
              resource.is_a? Class
            end
            .map do |resource|
              resources resource.route_key do
                member do
                  get :preview
                end
              end
            end
        end
      end
    end
  end
end
