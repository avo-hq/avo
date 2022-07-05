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

      route_key = resource.route_key
      # Add the `_index` suffix for the uncountable names so they get the correct path (`fish_index`)
      route_key << "_index" if resource.route_key == resource.singular_route_key

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

    def resource_attach_path(resource, model_id, related_name, related_id = nil)
      helpers.avo.resources_associations_new_path(resource.singular_route_key, model_id, related_name)
    end

    def resource_detach_path(
      model_name, # teams
      model_id, # 1
      related_name, # admin
      related_id = nil
    )
      avo.resources_associations_destroy_path(model_name, model_id, related_name, related_id)
    end

    def related_resources_path(
      parent_model,
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

      avo.resources_associations_index_path(parent_model.model_name.route_key, record.id, **existing_params, **args)
    end

    def order_up_resource_path(model:, resource:, **args)
      avo.send :"order_up_resources_#{resource.singular_route_key}_path", model, **args
    end
  end
end
