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
        params[:per_page] = 5
      end

      # Eager load the attachments
      query = eager_load_files(query)

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

      render json: {
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
      update_file_fields

      # Filter out the file params
      regular_resource_params = resource_params.select { |id, value| !avocado_resource.attached_file_fields.map(&:id).include? id }

      if avocado_resource.has_devise_password and regular_resource_params[:password].blank?
        regular_resource_params.delete(:password_confirmation)
        regular_resource_params.delete(:password)
      end

      avocado_resource.fill_model(resource, regular_resource_params).save!

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
        eager_load_files(resource_model.safe_constantize).find params[:id]
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
        permitted = resource_fields.select(&:updatable).map do |field|
          # If it's a relation
          if field.methods.include? :relation_method
            database_id = avocado_resource.model.reflections[field.relation_method].foreign_key
          end

          if database_id.present?
            # Allow the database_id for belongs_to relation
            database_id.to_sym
          elsif field.is_array_param
            # Allow array param if necessary
            { "#{field.id}": [] }
          else
            field.id.to_sym
          end
        end

        permitted
      end

      def resource_params
        params.require(:resource).permit(permitted_params)
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

      def eager_load_files(query)
        if avocado_resource.attached_file_fields.present?
          avocado_resource.attached_file_fields.map(&:id).map do |field|
            query = query.send :"with_attached_#{field}"
          end
        end

        query
      end

      def process_file_field(field, attachment)
        if attachment.is_a? ActionDispatch::Http::UploadedFile
          # New file has been attached
          field.attach attachment
        elsif attachment.blank?
          # File has been deleted
          field.purge
        elsif attachment.is_a? String
          # Field is unchanged
        end
      end

      def update_file_fields
        # Pick and attach file fields
        attached_file_fields = avocado_resource.attached_file_fields
        if attached_file_fields.present?
          file_fields_params = {}

          # Map params to fields
          attached_file_fields.each do |field|
            file_fields_params[field.id] = resource_params[field.id.to_sym]
          end

          file_fields_params.each do |id, attachment|
            # Identify field to make it easier to work with
            field = resource.send(id)

            if file_fields_params[id].is_a? Array
              # Get the ID's that we kept
              file_ids_kept = file_fields_params[id].select { |attachment| attachment.is_a? String }.map(&:to_i)
              # Compute the difference
              to_remove = field.pluck(:id) - file_ids_kept
              # Remove the missing ones
              to_remove.map { |attachment_id| field.find(attachment_id).purge }
            end

            # Figure out what has been submitted
            if attachment.is_a? Array
              # Files have been attached
              attachment.each do |attachment|
                process_file_field field, attachment
              end
            else
              process_file_field field, attachment
            end
          end
        end
      end
  end
end
