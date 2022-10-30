module Avo
  class DynamicRouter
    def self.routes
      Avo::Engine.routes.draw do
        scope "resources", as: "resources" do
          Avo::App.eager_load(:resources) unless Rails.application.config.eager_load

          BaseResource.descendants
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
