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

      path_key = resource.path_key
      # Add the `_index` suffix for the uncountable names so they get the correct path (`fish_index`)
      path_key << "_index" if resource.path_key == resource.singular_path_key

      avo.send :"resources_#{path_key}_path", **existing_params, **args
    end

    def resource_path(
      resource:,
      record: nil,
      resource_id: nil,
      keep_query_params: false,
      **args
    )
      avo.send :"resources_#{resource.singular_path_key}_path", record || resource_id, **args
    end

    def preview_resource_path(
      resource:,
      **args
    )
      avo.send :"preview_resources_#{resource.singular_path_key}_path", resource.record, **args
    end

    def new_resource_path(resource:, **args)
      avo.send :"new_resources_#{resource.singular_path_key}_path", **args
    end

    def edit_resource_path(resource:, record: nil, resource_id: nil, **args)
      avo.send :"edit_resources_#{resource.singular_path_key}_path", record || resource_id, **args
    end

    def resource_attach_path(resource, record_id, related_name, related_id = nil)
      helpers.avo.send(:"new_related_resources_#{resource.singular_path_key}_path", record_id, related_name)
    end

    def resource_detach_path(parent_resource:, resource:)
      avo.send(:"destroy_related_resources_#{resource.singular_path_key}_path", resource.record_param, resource.singular_path_key, parent_resource.record_param, parent_resource.singular_path_key)
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

      path_key = parent_resource&.singular_path_key || parent_record.model_name.route_key

      avo.send(:"index_related_resources_#{path_key}_path", record, **existing_params, **args)
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
