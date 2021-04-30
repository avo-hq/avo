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
        # Filter out the models without a ransack_query
        next if resource.ransack_query.nil?

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
      results = apply_search_metadata(resource.ransack_query.call(params: params).limit(8), resource)

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

        if resource.avatar_field.present?
          avatar = resource.avatar_field.to_image
          avatar_type = resource.avatar_field.as_avatar
        end

        begin
          description = resource.description_field.value
        rescue; end

        {
          _id: model.id,
          _label: resource.model_title,
          _description: description,
          _url: resource.avo_path,
          _avatar: avatar,
          _avatar_type: avatar_type,
          resource: resource,
          model: model
        }
      end
    end
  end
end
