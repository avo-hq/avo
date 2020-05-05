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
        resources_with_fields << Avocado::Resources::Resource.hydrate_resource(resource, avocado_resource, :index)
      end

      render json: {
        resources: resources_with_fields,
        per_page: per_page,
        total_pages: resources.total_pages,
      }
    end

    def search
      if params[:resource_name].present?
        resources = search_resource resource_model.safe_constantize
      else
        resources = []

        resources_to_search_through = App.get_resources.select { |r| r.search.present? }.map(&:model)

        resources_to_search_through.each do |resource_model|
          found_resources = add_link_to_search_results search_resource(resource_model)
          resources.push({
            label: resource_model.name,
            resources: found_resources
          })
        end
      end


      return render json: {
        resources: resources
      }
    end

    def show
      render json: {
        resource: Avocado::Resources::Resource.hydrate_resource(resource, avocado_resource, :show),
      }
    end

    def update
      resource.update(resource_params)

      render json: {
        resource: Avocado::Resources::Resource.hydrate_resource(resource, avocado_resource, :update),
        message: 'Resource updated',
      }
    end

    def create
      resource = resource_model.safe_constantize.new(resource_params)
      resource.save

      render json: {
        resource: Avocado::Resources::Resource.hydrate_resource(resource, avocado_resource, :create),
        message: 'Resource created',
        redirect_url: Avocado::Resources::Resource.show_path(resource),
      }
    end

    def fields
      resource = resource_model.safe_constantize.new

      render json: {
        resource: Avocado::Resources::Resource.hydrate_resource(resource, avocado_resource, :fields),
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

      def search_resource(resource)
        resource.fuzzy_search(name: params[:q])
      end

      def add_link_to_search_results(resources)
        resources.map do |model|
          resource = model.as_json
          resource[:link] = "/avocado/resources/#{model.class.to_s.singularize.underscore}/#{model.id}"

          resource
        end
      end
  end
end
