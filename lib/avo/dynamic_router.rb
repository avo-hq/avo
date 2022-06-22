module Avo
  module DynamicRouter
    class << self
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
              router.resources resource.new.route_key
            when 2
              router.namespace segments.first do
                router.resources segments.last
              end
            when 3
              router.namespace segments.first do
                router.namespace segments.second do
                  router.resources segments.last
                end
              end
            when 4
              router.namespace segments.first do
                router.namespace segments.second do
                  router.namespace segments.third do
                    router.resources segments.last
                  end
                end
              end
            when 5
              router.namespace segments.first do
                router.namespace segments.second do
                  router.namespace segments.third do
                    router.namespace segments.fourth do
                      router.resources segments.last
                    end
                  end
                end
              end
            when 6
              router.namespace segments.first do
                router.namespace segments.second do
                  router.namespace segments.third do
                    router.namespace segments.fourth do
                      router.namespace segments.fifth do
                        router.resources segments.last
                      end
                    end
                  end
                end
              end
            end
          end
      end
    end
  end
end

