require_dependency "avo/application_controller"

module Avo
  class SearchController < ApplicationController
    # before_action :authorize_user

    def index
      @authorization.set_record(resource_model).authorize_action :index
      resources = []

      App.get_resources
        .select { |resource| resource.search.present? }
        .select { |resource| AuthorizationService.authorize_action _current_user, resource.model, "index" }
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
          search_label: model.send(avo_resource.class.title),
          link: "/resources/#{model.class.to_s.singularize.underscore}/#{model.id}"
        }
      end
    end

    def search_resource(avo_resource)
      avo_resource.query_search(query: params[:q], via_resource_name: params[:via_resource_name], via_resource_id: params[:via_resource_id], user: _current_user)
    end

    # def authorize_user
    #   return if params[:action] == 'index'

    #   action = params[:action] == 'resource' ? :index : params[:action]

    #   return render_unauthorized unless AuthorizationService::authorize_action _current_user, avo_resource.model, action
    # end
  end
end
