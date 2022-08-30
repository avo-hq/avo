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
    alias :edit_field_wrapper :field_wrapper
    alias :show_field_wrapper :field_wrapper

    def filter_wrapper(name: nil, index: nil, **args, &block)
      render layout: "layouts/avo/filter_wrapper", locals: {
        name: name,
        index: index
      } do
        capture(&block)
      end
    end

    def item_selector_init(resource)
      "data-resource-name='#{resource.model_key}' data-resource-id='#{resource.model.id}' data-controller='item-selector'"
    end

    def item_selector_input(floating: false, size: :md)
      "<input type='checkbox'
        class='mx-3 rounded #{"absolute inset-auto left-0 mt-2 z-10 hidden group-hover:block checked:block" if floating} #{size.to_sym == :lg ? "w-5 h-5" : "w-4 h-4"}'
        data-action='input->item-selector#toggle input->item-select-all#selectRow'
        data-item-select-all-target='itemCheckbox'
        name='#{t "avo.select_item"}'
        title='#{t "avo.select_item"}'
        data-tippy='tooltip'
      />"
    end

    def item_select_all_input
      "<input type='checkbox'
        class='mx-3 rounded w-4 h-4'
        data-action='input->item-select-all#toggle'
        data-item-select-all-target='checkbox'
        name='#{t "avo.select_all"}'
        title='#{t "avo.select_all"}'
        data-tippy='tooltip'
      />"
    end
  end
end
