require_dependency "avocado/application_controller"

module Avocado
  class ResourcesController < ApplicationController
    def index
      resources = resource_model.safe_constantize.take(12)

      resources_with_fields = []
      resources.each do |resource|
        resource_with_fields = {
          id: resource.id,
          fields: [],
        }

        resource_fields.each do |field|
          resource_with_fields[:fields] << field.fetch_for_resource(resource)
        end
        resources_with_fields << resource_with_fields
      end

      render json: {
        resources: resources_with_fields
      }
    end

    def show
      resource = resource_model.safe_constantize.find params[:id]

      resource_with_fields = {
        id: resource.id,
        fields: [],
      }

      resource_fields.each do |field|
        resource_with_fields[:fields] << field.fetch_for_resource(resource)
      end

      render json: {
        resource: resource_with_fields
      }
    end

    private
      def resource_model
        "#{params[:resource].to_s.camelize.singularize}"
      end

      def avocado_resource
        App.get_resource resource_model
      end

      def resource_fields
        avocado_resource.get_fields
      end
  end
end
