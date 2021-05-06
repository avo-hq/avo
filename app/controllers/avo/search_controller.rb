require_dependency "avo/application_controller"

module Avo
  class SearchController < ApplicationController
    before_action :set_resource_name, only: [:show]
    before_action :set_resource, only: [:show]

    def index
      render json: search_resources(Avo::App.resources)
    end

    def show
      render json: search_resources([resource])
    end

    private

    def search_resources(resources)
      resources.map do |resource|
        # Apply authorization
        next unless @authorization.set_record(resource.model_class).authorize_action(:index, raise_exception: false)
        # Filter out the models without a search_query
        next if resource.search_query.nil?

        search_resource resource
      end
        .select do |payload|
          payload.present?
        end
        .sort do |payload|
          payload.last[:count]
        end
        .reverse
        .to_h
    end

    def search_resource(resource)
      results = apply_search_metadata(resource.search_query.call(params: params).limit(8), resource)

      result_object = {
        header: resource.name.pluralize,
        results: results,
        count: results.length
      }

      [resource.name.pluralize.downcase, result_object]
    end

    def apply_search_metadata(models, avo_resource)
      models.map do |model|
        resource = avo_resource.dup.hydrate(model: model).hydrate_fields(model: model)

        {
          _id: model.id,
          _label: resource.label,
          _description: resource.description,
          _url: resource.avo_path,
          _avatar: resource.avatar,
          _avatar_type: resource.avatar_type,
          model: model
        }
      end
    end
  end
end
