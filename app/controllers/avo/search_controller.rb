require_dependency "avo/application_controller"

module Avo
  class SearchController < ApplicationController
    include Rails.application.routes.url_helpers

    before_action :set_resource_name, only: [:show]
    before_action :set_resource, only: [:show]

    def index
      raise ActionController::BadRequest.new("This feature requires the pro license https://avohq.io/purchase/pro") if App.license.lacks_with_trial(:global_search)

      resources = Avo::App.resources.reject do |resource|
        resource.class.hide_from_global_search
      end

      render json: search_resources(resources)
    end

    def show
      render json: search_resources([resource])
    end

    private

    def search_resources(resources)
      resources
        .map do |resource|
          # Apply authorization
          next unless @authorization.set_record(resource.model_class).authorize_action(:index, raise_exception: false)
          # Filter out the models without a search_query
          next if resource.search_query.nil?

          search_resource resource
        end
        .select do |payload|
          payload.present?
        end
        .sort_by do |payload|
          payload.last[:count]
        end
        .reverse
        .to_h
    end

    def search_resource(resource)
      query = resource.search_query.call(params: params).limit(8)

      # Figure out if this is a belongs_to search
      query = apply_attach_scope query

      results = apply_search_metadata(query, resource)

      header = resource.plural_name

      if results.length > 0
        header += " (#{results.length})"
      end

      result_object = {
        header: header,
        help: resource.class.search_query_help,
        results: results,
        count: results.length
      }

      [resource.name.pluralize.downcase, result_object]
    end

    # Figure out if it's a belongs to search and if it has the attach_scope block present.
    # If so, set the parent for those edit view and the parent with the grandparent for the new view.
    def apply_attach_scope(query)
      return query if params[:via_reflection_class].blank?

      # Fetch the field
      field = belongs_to_field

      # No need to modify the query if there's no attach_scope present.
      return query if field.attach_scope.blank?

      # Try to fetch the parent.
      if params[:via_reflection_id].present?
        parent = params[:via_reflection_class].safe_constantize.find params[:via_reflection_id]
      end

      # If the parent is nil it probably means that someone's creating the record so it's not attached yet.
      # In these scenarios, try to find the grandparent for the new views where the parent is nil
      # and initialize the parent record with the grandparent attached so the user has the required information
      # to scope the query.
      if parent.blank? && params[:via_parent_resource_id].present? && params[:via_parent_resource_class].present? && params[:via_relation].present?
        grandparent = params[:via_parent_resource_class].safe_constantize.find params[:via_parent_resource_id]
        parent = params[:via_reflection_class].safe_constantize.new(
          params[:via_relation] => grandparent
        )
      end

      # Add to the query
      Avo::Hosts::AssociationScopeHost.new(block: belongs_to_field.attach_scope, query: query, parent: parent).handle
    end

    def apply_search_metadata(models, avo_resource)
      models.map do |model|
        resource = avo_resource.dup.hydrate(model: model).hydrate_fields(model: model)

        result = {
          _id: model.id,
          _label: resource.label,
          _url: resource.record_path,
        }

        if App.license.has_with_trial(:enhanced_search_results)
          result[:_description] = resource.description
          result[:_avatar] = resource.avatar.present? ? main_app.url_for(resource.avatar) : nil
          result[:_avatar_type] = resource.avatar_type
        end

        result
      end
    end

    def belongs_to_field
      fields = ::Avo::App.get_resource_by_model_name(params[:via_reflection_class]).get_field_definitions
      fields.find { |f| f.id.to_s == params[:via_association_id] }
    end
  end
end
