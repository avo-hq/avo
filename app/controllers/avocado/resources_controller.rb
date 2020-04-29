require_dependency "avocado/application_controller"

module Avocado
  class ResourcesController < ApplicationController
    def index
      per_page = 24
      params[:page] ||= 1
      params[:sort_by] = params[:sort_by].present? ? params[:sort_by] : :created_at
      params[:sort_direction] = params[:sort_direction].present? ? params[:sort_direction] : :desc

      resources = resource_model.safe_constantize.order("#{params[:sort_by]} #{params[:sort_direction]}").page(params[:page]).per(per_page)

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
        per_page: per_page,
        total_pages: resources.total_pages,
      }
    end

    def show
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
        resource: resource_with_fields,
      }
    end

    def update
      resource_with_fields = {
        id: resource.id,
        fields: [],
      }

      resource_fields.each do |field|
        resource_with_fields[:fields] << field.fetch_for_resource(resource)
      end

      resource.update(resource_params)

      render json: {
        resource: resource_with_fields,
        message: 'Resource updated',
      }
    end

    def create
      resource = resource_model.safe_constantize.new(resource_params)
      resource.save

      resource_with_fields = {
        id: resource.id,
        fields: [],
      }

      resource_fields.each do |field|
        resource_with_fields[:fields] << field.fetch_for_resource(resource)
      end

      render json: {
        resource: resource_with_fields,
        message: 'Resource created',
        redirect_url: Avocado::Resources::Resource.show_path(resource),
      }
    end

    def fields
      resource = resource_model.safe_constantize.new

      resource_with_fields = {
        id: resource.id,
        resource_name_singular: params[:resource_name].to_s.singularize,
        fields: [],
      }

      resource_fields.each do |field|
        resource_with_fields[:fields] << field.fetch_for_resource(resource)
      end

      # abort resource_fields.inspect

      render json: {
        resource: resource_with_fields
      }
    end

    def destroy
      resource.destroy

      render json: {
        redirect_url: Avocado::Resources::Resource.index_path(resource_model),
        message: 'Resource destroyed',
      }
    end

    private
      def resource
        resource_model.safe_constantize.find params[:id]
      end

      def resource_model
        params[:resource_name].to_s.camelize.singularize
      end

      def avocado_resource
        App.get_resource resource_model
      end

      def resource_fields
        avocado_resource.get_fields
      end

      def permitted_params
        resource_fields.select(&:can_be_updated).map(&:id).map(&:to_sym)
      end

      def resource_params
        params.require(:resource).permit(permitted_params)
      end
  end
end
