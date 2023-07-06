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
          next unless @authorization.set_record(resource.model_class).authorize_action(:search, raise_exception: false)

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
      query = Avo::Hosts::SearchScopeHost.new(
        block: resource.search_query,
        params: params,
        scope: resource.class.scope
      ).handle

      # Get the count
      results_count = query.reselect(resource.model_class.primary_key).count

      # Get the results
      query = query.limit(8)

      query = apply_scope(query) if should_apply_any_scope?

      results = apply_search_metadata(query, resource)

      header = resource.plural_name

      if results_count > 0
        header = "#{header} (#{results_count})"
      end

      result_object = {
        header: header,
        help: resource.class.search_query_help,
        results: results,
        count: results_count
      }

      [resource.name.pluralize.downcase, result_object]
    end

    # When searching in a `has_many` association and will scope out the records against the parent record.
    # This is also used when looking for `belongs_to` associations, and this method applies the parents `attach_scope` if present.
    def apply_scope(query)
      if should_apply_has_many_scope?
        apply_has_many_scope
      elsif should_apply_attach_scope?
        apply_attach_scope(query, parent)
      end
    end

    # Parent passed as argument to be used as a variable instead of the method "def parent"
    # Otherwise parent = params...safe_constantize... will try to call method "def parent="
    def apply_attach_scope(query, parent)
      # If the parent is nil it probably means that someone's creating the record so it's not attached yet.
      # In these scenarios, try to find the grandparent for the new views where the parent is nil
      # and initialize the parent record with the grandparent attached so the user has the required information
      # to scope the query.
      # Example usage: Got to a project, create a new review, and search for a user.
      if parent.blank? && params[:via_parent_resource_id].present? && params[:via_parent_resource_class].present? && params[:via_relation].present?
        parent_resource_class = BaseResource.valid_model_class params[:via_parent_resource_class]

        reflection_class = BaseResource.valid_model_class params[:via_reflection_class]

        grandparent = parent_resource_class.find params[:via_parent_resource_id]
        parent = reflection_class.new(
          params[:via_relation] => grandparent
        )
      end

      Avo::Hosts::AssociationScopeHost.new(block: attach_scope, query: query, parent: parent).handle
    end

    # This scope is applied if the search is being performed on a has_many association
    def apply_has_many_scope
      association_name = BaseResource.valid_association_name(parent, params[:via_association_id])

      # Get association records
      scope = parent.send(association_name)

      # Apply policy scope if authorization is present
      scope = resource.authorization&.apply_policy scope

      Avo::Hosts::SearchScopeHost.new(block: @resource.search_query, params: params, scope: scope).handle
    end

    def apply_search_metadata(models, avo_resource)
      models.map do |model|
        resource = avo_resource.dup.hydrate(model: model).hydrate_fields(model: model)

        record_path = if resource.search_result_path.present?
          Avo::Hosts::ResourceRecordHost.new(block: resource.search_result_path, resource: resource, record: model).handle
        else
          resource.record_path
        end

        result = {
          _id: model.id,
          _label: resource.label,
          _url: record_path
        }

        if App.license.has_with_trial(:enhanced_search_results)
          result[:_description] = resource.description
          result[:_avatar] = resource.avatar.present? ? main_app.url_for(resource.avatar) : nil
          result[:_avatar_type] = resource.avatar_type
        end

        result
      end
    end

    private

    def should_apply_has_many_scope?
      params[:via_association] == "has_many" && @resource.search_query.present?
    end

    def should_apply_attach_scope?
      params[:via_association] == "belongs_to" && attach_scope.present?
    end

    def should_apply_any_scope?
      should_apply_has_many_scope? || should_apply_attach_scope?
    end

    def attach_scope
      @attach_scope ||= field&.attach_scope
    end

    def field
      @field ||= fetch_field
    end

    def parent
      @parent ||= fetch_parent
    end

    def fetch_field
      fields = ::Avo::App.get_resource_by_model_name(params[:via_reflection_class]).get_field_definitions
      fields.find { |f| f.id.to_s == params[:via_association_id] }
    end

    def fetch_parent
      return unless params[:via_reflection_id].present?

      parent_resource = ::Avo::App.get_resource_by_model_name params[:via_reflection_class]
      parent_resource.find_record params[:via_reflection_id], params: params
    end
  end
end
