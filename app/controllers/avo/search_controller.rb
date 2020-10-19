require_dependency 'avo/application_controller'

module Avo
  class SearchController < ApplicationController
    before_action :authorize_user

    def index
      resources = []

      resources_to_search_through = App.get_resources.select { |r| r.search.present? }
        .each do |resource_model|
          found_resources = add_link_to_search_results(search_resource(resource_model), resource_model)
          resources.push({
            label: resource_model.name,
            resources: found_resources
          })
        end

      render json: {
        resources: resources
      }
    end

    def resource
      render json: {
        resources: add_link_to_search_results(search_resource(avo_resource), avo_resource)
      }
    end

    private
      def add_link_to_search_results(resources, avo_resource)
        resources.map do |model|
          {
            id: model.id,
            search_label: model.send(avo_resource.title),
            link: "/resources/#{model.class.to_s.singularize.underscore}/#{model.id}",
          }
        end
      end

      def search_resource(avo_resource)
        avo_resource.query_search(query: params[:q], via_resource_name: params[:via_resource_name], via_resource_id: params[:via_resource_id], user: current_user)
      end
  end
end
