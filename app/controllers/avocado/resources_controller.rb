require_dependency "avocado/application_controller"

module Avocado
  class ResourcesController < ApplicationController
    def index
      resources = resource_model.safe_constantize.take(12)

      resources_with_fields = []
      resources.each do |resource|
        resource_with_fields = {
          id: resource.id,
          resource_name_singular: params[:resource_name].to_s.singularize,
          title: resource[avocado_resource.title],
          fields: [],
        }

        resource_fields.each do |field|
          resource_with_fields[:fields] << field.fetch_for_resource(resource)
        end
        resources_with_fields << resource_with_fields
      end

      render json: {
        resources: resources_with_fields,
      }
    end

    def show
      resource = resource_model.safe_constantize.find params[:id]

      resource_with_fields = {
        id: resource.id,
        resource_name_singular: params[:resource_name].to_s.singularize,
        title: resource[avocado_resource.title],
        fields: [],
      }

      resource_fields.each do |field|
        resource_with_fields[:fields] << field.fetch_for_resource(resource)
      end

      render json: {
        resource: resource_with_fields
      }
    end

    def update
      resource = resource_model.safe_constantize.find params[:id]

      resource_with_fields = {
        id: resource.id,
        fields: [],
      }

      resource_fields.each do |field|
        resource_with_fields[:fields] << field.fetch_for_resource(resource)
      end

      permitted_params = resource_with_fields[:fields].select { |f| f[:can_be_updated] == true }.map { |f| f[:id].to_sym }
      resource.update(resource_params(permitted_params))

      render json: {
        resource: resource_with_fields,
        message: 'Resource updated',
      }
    end

    def fields
      # resource = resource_model.safe_constantize.find params[:id]

      resource_with_fields = {
        # id: resource.id,
        resource_name_singular: params[:resource_name].to_s.singularize,
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
        params[:resource_name].to_s.camelize.singularize
      end

      def avocado_resource
        App.get_resource resource_model
      end

      def resource_fields
        avocado_resource.get_fields
      end

      def resource_params(permitted_params)
        params.require(:resource).permit(permitted_params)
      end
  end
end
