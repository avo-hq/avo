require_dependency 'avo/application_controller'

module Avo
  class ResourcesController < ApplicationController
    before_action :authorize_user

    def index
      params[:page] ||= 1
      params[:per_page] ||= Avo.configuration.per_page
      params[:sort_by] = params[:sort_by].present? ? params[:sort_by] : :created_at
      params[:sort_direction] = params[:sort_direction].present? ? params[:sort_direction] : :desc

      query = AuthorizationService.with_policy current_user, resource_model

      if params[:via_resource_name].present? and params[:via_resource_id].present? and params[:via_relationship].present?
        # get the related resource (via_resource)
        related_model = App.get_resource_by_name(params[:via_resource_name]).model

        relation = related_model.find(params[:via_resource_id]).public_send(params[:via_relationship])
        query = AuthorizationService.with_policy current_user, relation

        params[:per_page] = Avo.configuration.via_per_page
      elsif ['has_many', 'has_and_belongs_to_many'].include? params[:for_relation]
        # has_many searchable query
        resources = resource_model.all.map do |model|
          {
            value: model.id,
            label: model.send(avo_resource.title),
          }
        end

        return render json: {
          resources: resources
        }
      end

      query = query.order("#{params[:sort_by]} #{params[:sort_direction]}")

      applied_filters.each do |filter_class, filter_value|
        query = filter_class.safe_constantize.new.apply_query request, query, filter_value
      end

      # Eager load the attachments
      query = eager_load_files(query)

      # Eager load the relations
      if avo_resource.includes.present?
        query = query.includes(*avo_resource.includes)
      end

      resources = query.page(params[:page]).per(params[:per_page])

      resources_with_fields = []
      resources.each do |resource|
        resources_with_fields << Avo::Resources::Resource.hydrate_resource(model: resource, resource: avo_resource, view: :index, user: current_user)
      end

      render json: {
        success: true,
        meta: build_meta,
        resources: resources_with_fields,
        per_page: params[:per_page],
        total_pages: resources.total_pages,
      }
    end

    def show
      render json: {
        resource: Avo::Resources::Resource.hydrate_resource(model: resource, resource: avo_resource, view: @view || :show, user: current_user),
      }
    end

    def edit
      @view = :edit

      show
    end

    def update
      update_file_fields

      # Filter out the file params
      regular_resource_params = resource_params.select do |id, value|
        !avo_resource.attached_file_fields.map(&:id).to_s.include? id
      end

      if avo_resource.has_devise_password and regular_resource_params[:password].blank?
        regular_resource_params.delete(:password_confirmation)
        regular_resource_params.delete(:password)
      end

      casted_params = cast_nullable(regular_resource_params)
      avo_resource.fill_model(resource, casted_params).save!

      render json: {
        success: true,
        resource: Avo::Resources::Resource.hydrate_resource(model: resource, resource: avo_resource, view: :show, user: current_user),
        message: I18n.t('avo.resource_updated'),
      }
    end

    def create
      create_params = resource_params

      # Update the foreign key for a belongs_to relation from a has_many via creation.
      if params[:via_relationship].present?
        relationship_foreign_key = params[:via_resource_name].singularize.camelize.safe_constantize.reflections[params[:via_relationship]].foreign_key
        if create_params[relationship_foreign_key].blank?
          create_params[relationship_foreign_key] = params[:via_resource_id]
        end
      end

      casted_params = cast_nullable(create_params)

      resource = resource_model.new(casted_params)
      resource.save!

      render json: {
        success: true,
        resource: Avo::Resources::Resource.hydrate_resource(model: resource, resource: avo_resource, view: :create, user: current_user),
        message: I18n.t('avo.resource_created'),
      }
    end

    def new
      render json: {
        resource: Avo::Resources::Resource.hydrate_resource(model: resource_model.new, resource: avo_resource, view: :create, user: current_user),
      }
    end

    def destroy
      resource.destroy!

      render json: {
        message: I18n.t('avo.resource_destroyed'),
      }
    end

    private
      def permitted_params
        permitted = avo_resource.get_fields.select(&:updatable).map do |field|
          # If it's a relation
          if field.methods.include? :foreign_key
            database_id = field.foreign_key(avo_resource.model)
          end

          if database_id.present?
            # Allow the database_id for belongs_to relation
            database_id.to_sym
          elsif field.is_array_param
            # Allow array param if necessary
            { "#{field.id}": [] }
          elsif field.is_object_param
            # Allow array param if necessary
            [:"#{field.id}", "#{field.id}": {} ]
          else
            field.id.to_sym
          end
        end

        permitted
      end

      def resource_params
        params.require(:resource).permit(permitted_params)
      end

      def update_file_fields
        # Pick and attach file fields
        attached_file_fields = avo_resource.attached_file_fields
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

      def applied_filters
        if params[:filters].present?
          return JSON.parse(Base64.decode64(params[:filters]))
        end

        filter_defaults = {}

        avo_resource.get_filters.each do |filter_class|
          filter = filter_class.new

          if filter.default.present?
            filter_defaults[filter_class.to_s] = filter.default
          end
        end

        filter_defaults
      end

      def cast_nullable(params)
        fields = avo_resource.get_fields

        nullable_fields = fields.filter { |field| field.nullable }
                                .map { |field| [field.id, field.null_values] }
                                .to_h

        params.each do |key, value|
          nullable = nullable_fields[key.to_sym]

          if nullable.present? && value.in?(nullable)
            params[key] = nil
          end
        end

        params
      end

      def build_meta
        {
          per_page_steps: Avo.configuration.per_page_steps,
          available_view_types: avo_resource.available_view_types,
          default_view_type: avo_resource.default_view_type || Avo.configuration.default_view_type,
          translation_key: avo_resource.translation_key,
          authorization: {
            create: AuthorizationService::authorize(current_user, avo_resource.model, Avo.configuration.authorization_methods.stringify_keys['create']),
            edit: AuthorizationService::authorize(current_user, avo_resource.model, Avo.configuration.authorization_methods.stringify_keys['edit']),
            update: AuthorizationService::authorize(current_user, avo_resource.model, Avo.configuration.authorization_methods.stringify_keys['update']),
            show: AuthorizationService::authorize(current_user, avo_resource.model, Avo.configuration.authorization_methods.stringify_keys['show']),
            destroy: AuthorizationService::authorize(current_user, avo_resource.model, Avo.configuration.authorization_methods.stringify_keys['destroy']),
          },
        }
      end
  end
end
