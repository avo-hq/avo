module Avo
  module ResourcesHelper
    def resource_table(resources, resource)
      render partial: "avo/partials/resource_table", locals: {
        resources: resources,
        resource: resource
      }
    end

    def resource_grid(resources, resource)
      render partial: "avo/partials/resource_grid", locals: {
        resources: resources,
        resource: resource
      }
    end

    def index_field_wrapper(**args, &block)
      render Index::FieldWrapperComponent.new(**args) do
        capture(&block)
      end
    end

    def field_wrapper(**args, &block)
      render Avo::FieldWrapperComponent.new(**args) do
        capture(&block)
      end
    end
    alias_method :edit_field_wrapper, :field_wrapper
    alias_method :show_field_wrapper, :field_wrapper

    def filter_wrapper(name: nil, index: nil, **args, &block)
      render layout: "layouts/avo/filter_wrapper", locals: {
        name: name,
        index: index
      } do
        capture(&block)
      end
    end

    def item_selector_data_attributes(resource, controller: "")
      {
        resource_name: resource.model_key,
        resource_id: resource.record.to_param,
        controller: "item-selector #{controller}"
      }
    end

    def resource_show_path(resource:, parent_resource: nil, parent_record: nil, parent_or_child_resource: nil)
      args = {}

      if parent_record.present?
        args = {
          via_resource_class: parent_resource.class.to_s,
          via_record_id: parent_record.to_param
        }
      end

      resource_path(record: resource.record, resource: parent_or_child_resource, **args)
    end
  end
end
