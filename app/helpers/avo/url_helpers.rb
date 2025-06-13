module Avo
  module URLHelpers
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
      resource:,
      record: nil,
      resource_id: nil,
      keep_query_params: false,
      **args
    )
      avo.send :"resources_#{resource.singular_route_key}_path", record || resource_id, **args
    end

    def preview_resource_path(
      resource:,
      **args
    )
      avo.send :"preview_resources_#{resource.singular_route_key}_path", resource.record, **args
    end

    def new_resource_path(resource:, **args)
      avo.send :"new_resources_#{resource.singular_route_key}_path", **args
    end

    def edit_resource_path(resource:, record: nil, resource_id: nil, **args)
      avo.send :"edit_resources_#{resource.singular_route_key}_path", record || resource_id, **args
    end

    def resource_attach_path(resource, record_id, related_name, related_id = nil)
      helpers.avo.resources_associations_new_path(resource.singular_route_key, record_id, related_name)
    end

    def resource_detach_path(
      model_name, # teams
      record_id, # 1
      related_name, # admin
      related_id = nil
    )
      avo.resources_associations_destroy_path(model_name, record_id, related_name, related_id)
    end

    def related_resources_path(
      parent_record,
      record,
      keep_query_params: false,
      parent_resource: nil,
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

      route_key = parent_resource&.route_key || parent_record.model_name.route_key

      avo.resources_associations_index_path(route_key, record.to_param, **existing_params, **args)
    end

    def resource_view_path(**args)
      if Avo.configuration.resource_default_view.edit?
        edit_resource_path(**args)
      else
        resource_path(**args)
      end
    end
  end
end
