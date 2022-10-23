module Avo
  class DynamicRouter
    def self.routes
      Avo::Engine.routes.draw do
        scope "resources", as: "resources" do
          Avo::App.eager_load :resources

          BaseResource.descendants
            .select do |resource|
              resource != :BaseResource
            end
            .select do |resource|
              resource.is_a? Class
            end
            # .select do |resource|
            #   resource.model_class.present?
            # end
            .map do |resource|
              resources resource.new.route_key
            end
        end
      end
    end
  end
end
