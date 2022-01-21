module Avo
  module UrlHelpers
    def resources_path(model, for_resource:, keep_query_params: false, **args)
      return if model.nil?

      class_name = plural_resource_name(model, for_resource)

      existing_params = {}

      begin
        if keep_query_params
          existing_params =
            Addressable::URI.parse(request.fullpath).query_values.symbolize_keys
        end
      rescue
      end
      avo.send :"resources_#{class_name}_path", **existing_params, **args
    end

    def related_resources_path(
      parent_model,
      model,
      keep_query_params: false,
      **args
    )
      return if model.nil?

      existing_params = {}

      begin
        if keep_query_params
          existing_params =
            Addressable::URI.parse(request.fullpath).query_values.symbolize_keys
        end
      rescue
      end

      avo.resources_associations_index_path(@parent_resource.model_class.model_name.route_key, @parent_resource.model.id, **existing_params, **args )
    end

    def resource_path(
      model = nil,
      for_resource:,
      resource_id: nil,
      keep_query_params: false,
      **args
    )
      class_name = singular_resource_name(model, for_resource)

      if resource_id.present?
        return avo.send :"resources_#{class_name}_path", resource_id, **args
      end

      avo.send :"resources_#{class_name}_path", model, **args
    end

    def new_resource_path(model, for_resource:, **args)
      class_name = singular_resource_name(model, for_resource)

      avo.send :"new_resources_#{class_name}_path", **args
    end

    def edit_resource_path(model, for_resource:, **args)
      class_name = singular_resource_name(model, for_resource)

      avo.send :"edit_resources_#{class_name}_path", model, **args
    end

    def resource_attach_path(resource, model_id, related_name, related_id = nil)
      class_name = helpers.singular_resource_name(nil, resource)

      helpers.avo.resources_associations_new_path(class_name, model_id, related_name)
    end

    def resource_detach_path(
      model_name, # teams
      model_id, # 1
      related_name, # admin
      related_id = nil
    )
      avo.resources_associations_destroy_path(model_name, model_id, related_name, related_id)
    end

    private

    # This method figures out the the name of the model from the model or the resource.
    # This is needed when dealing with STI models.
    def singular_resource_name(model, resource)
      singular_name(model_class(model, resource))
    end

    # This method figures out the the name of the model from the model or the resource.
    # This is needed when dealing with STI models.
    def plural_resource_name(model, resource)
      model_class(model, resource).model_name.route_key
    end

    def model_class(model, resource)
      if resource.present?
        resource.model_class
      else
        model
      end
    end
  end
end
