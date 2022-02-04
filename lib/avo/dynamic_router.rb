module Avo
  module DynamicRouter
    def self.routes(router)
      Rails.application.eager_load!

      BaseResource.descendants
        .select do |resource|
          resource != :BaseResource
        end
        .select do |resource|
          resource.is_a? Class
        end
        .map do |resource|
          router.resources resource.new.model_key
        end
    end
  end
end
