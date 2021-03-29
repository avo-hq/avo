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

    def index_field(field, index, resource)
      component = field.component_name(:index)

      if Object.const_defined? component
        render component.safe_constantize.new(field: field, resource: resource, index: index)
      else
        render partial: field.partial_path_for(:index), locals: {
          field: field,
          index: index,
          resource: resource
        }
      end
    end

    def show_field(field, index, resource)
      component = field.component_name(:show)

      if Object.const_defined? component
        render component.safe_constantize.new(field: field, resource: resource, index: index)
      else
        render partial: field.partial_path_for(:show), locals: {
          field: field,
          index: index,
          resource: resource
        }
      end
    end

    def edit_field(field, index, resource, form, displayed_in_modal: false)
      component = field.component_name(:edit)

      if Object.const_defined? component
        render component.safe_constantize.new(field: field, resource: resource, index: index, form: form, displayed_in_modal: displayed_in_modal)
      else
        render partial: field.partial_path_for(:edit), locals: {
          field: field,
          index: index,
          resource: resource,
          form: form,
          displayed_in_modal: displayed_in_modal
        }
      end
    end

    def index_field_wrapper(**args, &block)
      render Index::FieldWrapperComponent.new(**args) do
        capture(&block)
      end
    end

    def show_field_wrapper(**args, &block)
      render Show::FieldWrapperComponent.new(**args) do
        capture(&block)
      end
    end

    def edit_field_wrapper(**args, &block)
      render Edit::FieldWrapperComponent.new(**args) do
        capture(&block)
      end
    end

    def filter_wrapper(name: nil, index: nil, **args, &block)
      render layout: "layouts/avo/filter_wrapper", locals: {
        name: name,
        index: index
      } do
        capture(&block)
      end
    end

    def item_selector_init(resource)
      "data-resource-name='#{resource.plural_name.downcase}' data-resource-id='#{resource.model.id}' data-controller='item-selector'"
    end

    def item_selector_input(floating: false, size: :md)
      "<input type='checkbox'
        class='mx-3 #{"absolute inset-auto left-0 mt-2 z-10 hidden group-hover:block checked:block" if floating} #{size.to_sym == :lg ? "w-5 h-5" : "w-4 h-4"}'
        data-action='input->item-selector#toggle'
        title='#{t "avo.select_item"}'
        data-tippy='tooltip'
      />"
    end
  end
end
