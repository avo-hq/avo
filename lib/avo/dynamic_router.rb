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
          # router.resources route_key,
          #   controller: "associations",
          #   constraints: ->(request) do
          #     # request.params[:resource_class].present? || request.params[:for_association].present?
          #     # request.params[:resource_name].present?
          #     # request.params[:field_id].present?
          #     request.params[:associated_resource_class].present?
          #   end
          # stand-alone association routes
          # router.resources route_key,
          #   controller: "associations",
          #   as: "#{route_key}_association",
          #   only: [:new],
          #   constraints: ->(request) do
          #     # request.params[:in_association].present?
          #     request.params[:associated_resource_class].present?
          #   end

          # regular routes
          router.resources route_key, as: route_key do
            #  TODO: make this dynamic
            # Find has_one associations
            # Find has_many associations
            router.resources :users,
              controller: '/users'
            router.resources :comments,
              # module:
              as: 'comments',
              controller: '/avo/comments'
              router.namespace :wonka do
                router.namespace :donka do
                  router.resources :comments,
                    # module:
                    as: 'comments',
                    controller: '/avo/wonka/donka/comments'
                end
              end
          end


# Sa incercam cum are sens pentru rails
# daca se ataseaza un comment pe un post merge pe calea
# /admin/resources/posts/5/comments/new
# un exemplu mai complex
# /admin/resources/super/duper/posts/5/wonka/donka/comments/new
# - rutele se genereaza pe naming scheme-ul resursei, nu modelului
# - controllerele trebuie sa respecte acel naming scheme
# - in declararea rutelor mentionam si controllerul
# - la declararea rutelor vedem ce fields sunt pe resursa si cream pe loc acele rute

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

            # Form segment.count == 2
            # we manually nest the namespaces in order to avoid the complexity around programatically nesting them.
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

