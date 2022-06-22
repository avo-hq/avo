module Avo
  module DynamicRouter
    def self.routes(router)
      Rails.application.eager_load! unless Rails.env.production?

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
          route_key = resource.new.route_key
          segments = route_key.split "/"

          if segments.count == 1
            router.resources resource.new.route_key
          else
            last = segments.pop

            router.namespace segments.join('/').to_sym do
              router.resources last
            end
          end
        end
    end
  end
end
