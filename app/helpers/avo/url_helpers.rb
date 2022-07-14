module Avo
  module UrlHelpers
    def resources_path(resource:, keep_query_params: false, **args)
      return if resource.nil?

      existing_params = {}
      if keep_query_params
        begin
          existing_params =
            Addressable::URI.parse(request.fullpath).query_values.symbolize_keys
        rescue
        end
      end

      route_key = resource.url_route_key
      # Add the `_index` suffix for the uncountable names so they get the correct path (`fish_index`)
      route_key << "_index" if resource.url_route_key == resource.singular_route_key

      avo.send :"resources_#{route_key}_path", **existing_params, **args
    end

    def resource_path(
      model:,
      resource:,
      resource_id: nil,
      keep_query_params: false,
      **args
    )
      if model.respond_to? :id
        id = model
      elsif resource_id.present?
        id = resource_id
      end

      avo.send :"resources_#{resource.singular_route_key}_path", id, **args
    end

    def new_resource_path(resource:, **args)
      avo.send :"new_resources_#{resource.singular_route_key}_path", **args
    end

    def edit_resource_path(model:, resource:, **args)
      avo.send :"edit_resources_#{resource.singular_route_key}_path", model, **args
    end

    # def resource_attach_path(resource, model_id, related_name, related_id = nil)
    #   helpers.avo.resources_associations_new_path(resource.singular_route_key, model_id, related_name)
    # end

    def resource_detach_path(
      model:,
      resource:,
      # model_name, # super/duper/project
      # model_id, # project_id: 1
      **args
      # args: {
      #   related_name, # review
      #   related_id # review_id: 1
      # }
    )
      ""
      # abort [resource ].inspect
      # avo.send(:"resources_associations_destroy_path", model_name, model_id, related_name, related_id)
      avo.send(:"resources_#{resource.singular_route_key}_path", model.id, **args)
    end

    def related_resources_path(
      resource,
      record,
      keep_query_params: false,
      **args
    )
      return if record.nil?

      existing_params = {}

      begin
        if keep_query_params
          existing_params =
            Addressable::URI.parse(request.fullpath).query_values.symbolize_keys
        end
      rescue
      end

      return '123'

      count = resource.class.to_s.split("::").count
      avo.send(:"resources_associations_index_#{count}_path", record.model_name.route_key, record.id, **existing_params, **args)
    end

    # def order_up_resource_path(model:, resource:, **args)
    #   avo.send :"order_up_resources_#{resource.singular_route_key}_path", model, **args
    # end
  end
end
