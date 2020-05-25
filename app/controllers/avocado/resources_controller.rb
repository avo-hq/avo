require_dependency "avocado/application_controller"

module Avocado
  class ResourcesController < ApplicationController
    def index
      params[:page] ||= 1
      params[:per_page] ||= 25
      params[:sort_by] = params[:sort_by].present? ? params[:sort_by] : :created_at
      params[:sort_direction] = params[:sort_direction].present? ? params[:sort_direction] : :desc
      filters = params[:filters].present? ? JSON.parse(Base64.decode64(params[:filters])) : {}

      query = resource_model.safe_constantize.order("#{params[:sort_by]} #{params[:sort_direction]}")
      if filters.present?
        filters.each do |filter_class, filter_value|
          query = filter_class.safe_constantize.new.apply_query request, query, filter_value
        end
      end

      if params[:via_resource_name].present? and params[:via_resource_id].present?
        # get the reated resource (via_resource)
        related_resource = App.get_resource_by_name(params[:via_resource_name])
        related_model = related_resource.model
        # fetch the entries
        query = related_model.find(params[:via_resource_id]).public_send(params[:resource_name])
      end

      # Eager load the attachments
      if avocado_resource.has_file_fields_attached?
        avocado_resource.file_fields_attached.map(&:id).map do |field|
          query = query.send :"with_attached_#{field}"
        end
      end

      # Eager lood the relations
      if avocado_resource.includes.present?
        query = query.includes(*avocado_resource.includes)
      end

      resources = query.page(params[:page]).per(params[:per_page])

      resources_with_fields = []
      resources.each do |resource|
        resources_with_fields << Avocado::Resources::Resource.hydrate_resource(resource, avocado_resource, :index)
      end

      render json: {
        resources: resources_with_fields,
        per_page: params[:per_page],
        total_pages: resources.total_pages,
      }
    end

    def search
      if params[:resource_name].present?
        resources = add_link_to_search_results search_resource(avocado_resource)
      else
        resources = []

        resources_to_search_through = App.get_resources.select { |r| r.search.present? }
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
        resource: Avocado::Resources::Resource.hydrate_resource(resource, avocado_resource, @view || :show),
      }
    end

    def edit
      @view = :edit

      show
    end

    def update
      # abort permitted_params.inspect
      if avocado_resource.has_file_fields_attached?
        file_fields_params = {}
        file_fields = avocado_resource.file_fields_attached

        file_fields.each do |field|
          file_fields_params[field.id] = params[field.id]
        end

        params = resource_params.select { |id, value| !file_fields.map(&:id).include? id }

        # abort file_params.inspect
        # abort [file_params, file_fields_params, params].inspect

        file_params.each do |id, params_value|
          file_field = file_fields.select { |field| field.id === id }
          # abort id.inspect
          field = resource.send(id)
          # abort [params_value[:file]].inspect

          # form
          next if params_value[:has_changed] == 'false'

          if params_value[:file].present?
            t= field.attached?
            if !field.attached? or params_value[:has_changed] == 'true'
              field.attach params_value[:file]
            end
          else
            field.purge
          end
        end
      end

      resource.update!(params)

      render json: {
        resource: Avocado::Resources::Resource.hydrate_resource(resource, avocado_resource, :show),
        message: 'Resource updated',
        redirect_url: Avocado::Resources::Resource.show_path(resource),
      }
    end

    def create
      resource = resource_model.safe_constantize.new(resource_params)
      resource.save!

      render json: {
        resource: Avocado::Resources::Resource.hydrate_resource(resource, avocado_resource, :create),
        message: 'Resource created',
        redirect_url: Avocado::Resources::Resource.show_path(resource),
      }
    end

    def fields
      resource = resource_model.safe_constantize.new

      render json: {
        resource: Avocado::Resources::Resource.hydrate_resource(resource, avocado_resource, :create),
      }
    end

    def destroy
      resource.destroy!

      render json: {
        redirect_url: Avocado::Resources::Resource.index_path(resource_model),
        message: 'Resource destroyed',
      }
    end

    def filters
      avocado_filters = avocado_resource.get_filters
      filters = []

      avocado_filters.each do |filter|
        filters.push(filter.new.render_response)
      end

      render json: {
        filters: filters,
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
        params = resource_fields.select { |field| !field.is_file_field }.select(&:updatable).map do |field|
          if field.methods.include? :relation_method
            db_field = avocado_resource.model.reflections[field.relation_method].foreign_key
          end

          if db_field.present?
            db_field.to_sym
          else
            field.id
          end
        end

        params.map(&:to_sym)
      end

      def permitted_file_params
        resource_fields
          .select { |field| field.is_file_field }
          .select(&:updatable)
          .map(&:id)
          .map(&:to_sym)
          .map { |field_id| [field_id, [:has_changed, :file]] }.to_h
      end

      def resource_params
        params.require(:resource).permit(permitted_params)
      end

      def file_params
        params.require(:file_fields).permit(permitted_file_params)
      end

      def search_resource(avocado_resource)
        avocado_resource.query_search(query: params[:q], via_resource_name: params[:via_resource_name], via_resource_id: params[:via_resource_id])
      end

      def add_link_to_search_results(resources)
        resources.map do |model|
          resource = model.as_json
          resource[:link] = "/resources/#{model.class.to_s.singularize.underscore}/#{model.id}"

          resource
        end
      end
  end
end
