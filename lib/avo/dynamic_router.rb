module Avo
  module DynamicRouter
    class << self
      def register_resource(router, route_key, segments: [])
        -> {

          # begin
          #   router.get "/:resource_name/:id/:related_name/new", to: "/avo/associations#new", as: "associations_new_#{segments.count}"
          #   router.get "/:resource_name/:id/:related_name/", to: "/avo/associations#index", as: "associations_index_#{segments.count}"
          # rescue => exception

          # end
          # router.get "/:resource_name/:id/:related_name/", to: "associations#index", as: "associations_index"
          # router.resources route_key, only: [:index], controller: '/avo/associations', constraints: lambda { |req| req.params[:resource_class].present? }


          # association routes
          router.resources route_key,
            controller: "associations",
            constraints: ->(request) do
              # request.params[:for_resource_klass].present? || request.params[:for_association].present?
              request.params[:for_resource_klass].present?
            end

          # regular routes
          router.resources route_key



          # member do

          # end

          # router.get "/:resource_name/:id/:related_name/", to: "associations#index", as: "associations_index"
          # router.get "/:resource_name/:id/:related_name/:related_id", to: "associations#show", as: "associations_show"
          # router.post "/:resource_name/:id/:related_name", to: "associations#create", as: "associations_create"
          # router.delete "/:resource_name/:id/:related_name/:related_id", to: "associations#destroy", as: "associations_destroy"
        }
      end

      def routes(router)
        Rails.application.eager_load! unless Rails.env.production?

        BaseResource.descendants
          .select do |resource|
            resource != :BaseResource
          end
          .select do |resource|
            resource.is_a? Class
          end
          .map do |resource|
            route_key = resource.new.route_key
            segments = route_key.split "/"

            # Form segment.count == 2 we manually nest the namespaces in order to avoid the complexity around programatically nesting them.
            case segments.count
            when 1
              instance_exec &register_resource(router, resource.new.route_key, segments: segments)
            when 2
              router.namespace segments.first do
                instance_exec &register_resource(router, segments.last, segments: segments)
              end
            when 3
              router.namespace segments.first do
                router.namespace segments.second do
                  instance_exec &register_resource(router, segments.last, segments: segments)
                end
              end
            # when 4
            #   router.namespace segments.first do
            #     router.namespace segments.second do
            #       router.namespace segments.third do
            #         register_resource(router, segments.last, count: segments.count).call
            #       end
            #     end
            #   end
            # when 5
            #   router.namespace segments.first do
            #     router.namespace segments.second do
            #       router.namespace segments.third do
            #         router.namespace segments.fourth do
            #           register_resource(router, segments.last, count: segments.count).call
            #         end
            #       end
            #     end
            #   end
            # when 6
            #   router.namespace segments.first do
            #     router.namespace segments.second do
            #       router.namespace segments.third do
            #         router.namespace segments.fourth do
            #           router.namespace segments.fifth do
            #             register_resource(router, segments.last, count: segments.count).call
            #           end
            #         end
            #       end
            #     end
            #   end
            end
          end
      end
    end
  end
end

