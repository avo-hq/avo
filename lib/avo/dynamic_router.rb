module Avo
  class DynamicRouter
    def self.routes
      Avo::Engine.routes.draw do
        scope "resources", as: "resources" do
          # Check if the user chose to manually register the resource files.
          # If so, eager_load the resources dir.
          if Avo.configuration.resources.nil?
            Avo::App.eager_load(:resources) unless Rails.application.config.eager_load
          end

          Avo::App.fetch_resources
            .select do |resource|
              resource != :BaseResource
            end
            .select do |resource|
              resource.is_a? Class
            end
            .map do |resource|
              resources resource.new.route_key
            end
        end
      end
    end
  end
end
