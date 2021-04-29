require_dependency "avo/application_controller"

module Avo
  class SearchController < ApplicationController
    before_action :set_resource_name, only: [:resource_search]
    before_action :set_resource, only: [:resource_search]
    # before_action :set_model, only: [:resource_search]
    # before_action :authorize_user

    def index
      results = Avo::App.resources.map do |resource|
        next if resource.ransack_query.nil?

        results = add_link_to_search_results(resource.ransack_query.call(params: params).limit(8), resource)

        result_object = {
          header: resource.name.pluralize,
          results: results,
          count: results.length
        }

        [resource.name.pluralize.downcase, result_object]
      end
        .select do |payload|
          payload.present?
        end
        .sort do |payload|
          payload.last[:count]
        end
        .reverse
        .to_h

      render json: results

      # @authorization.set_record(resource_model).authorize_action :index
      # resources = []

      # App.resources
      #   .select { |resource| resource.search.present? }
      #   .select { |resource| AuthorizationService.authorize_action _current_user, resource.model, "index" }
      #   .each do |resource_model|
      #     found_resources = add_link_to_search_results(search_resource(resource_model), resource_model)
      #     resources.push({
      #       label: resource_model.name,
      #       resources: found_resources
      #     })
      #   end

      # render json: {
      #   resources: resources
      # }
    end

    def resource_search
      # abort @resource.inspect
      # model_search_attributes = @resource.search
      # model_search_predicates = @resource.ransack_predicates

      # ransack_arguments = {}
      # model_search_attributes.each do |attribute|
      #   model_search_predicates.each do |predicate|
      #     ransack_predicate = predicate.gsub("*_", "#{attribute}_")
      #     ransack_arguments[ransack_predicate.to_sym] = params[:q]
      #   end
      # end

      # abort ransack_arguments.inspect

      # abort model_search_attributes.inspect
      # @q = @resource.model_class.ransack(**ransack_arguments)
      # @people = @q.result(distinct: false).limit(3)

      return render json: add_link_to_search_results(@resource.ransack_query.call(params: params).limit(3), @resource)
      # abort params.inspect
      # render json: {
      #   resources: add_link_to_search_results(search_resource(avo_resource), avo_resource)
      # }
    end

    private

    def add_link_to_search_results(models, avo_resource)
      models.map do |model|
        resource = avo_resource.dup.hydrate(model: model)
        {
          _id: model.id,
          _label: resource.model_title,
          _url: resource.avo_path,
          resource: resource,
          model: model
        }
      end
    end

    def search_resource(avo_resource)
      avo_resource.query_search(query: params[:q], via_resource_name: params[:via_resource_name], via_resource_id: params[:via_resource_id], user: _current_user)
    end

    # def authorize_user
    #   return if params[:action] == 'index'

    #   action = params[:action] == 'resource' ? :index : params[:action]

    #   return render_unauthorized unless AuthorizationService::authorize_action _current_user, avo_resource.model, action
    # end
  end
end
