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

    def item_selector_init(resource)
      "data-resource-name='#{resource.model_key}' data-resource-id='#{resource.record.to_param}' data-controller='item-selector'"
    end

    def item_selector_input(floating: false, size: :md, classes: "")
      if floating
        floating_class = { left: "left-0", right: "right-0" }
        floating_class.default = "left-0"
        classes += " absolute inset-auto mt-3 z-10 hidden group-hover:block checked:block #{floating_class[floating]}"
      end

      size_classes = { md: "w-4 h-4", lg: "w-5 h-5" }
      size_classes.default = "w-4 h-4"
      tag :input,
        type: "checkbox",
        name: t("avo.select_item"),
        title: t("avo.select_item"),
        autocomplete: :off,
        class: "#{classes} mx-3 rounded checked:bg-primary-400 focus:checked:!bg-primary-400 #{size_classes[size.to_sym]}",
        data: {
          action: 'input->item-selector#toggle input->item-select-all#selectRow',
          item_select_all_target: 'itemCheckbox',
          tippy: 'tooltip'
        }
    end

    def item_select_all_input
      tag :input,
        type: "checkbox",
        name: t("avo.select_all"),
        title: t("avo.select_all"),
        autocomplete: :off,
        class: "mx-3 rounded w-4 h-4 checked:bg-primary-400 focus:checked:!bg-primary-400",
        data: {
          action: "input->item-select-all#toggle",
          item_select_all_target: "checkbox",
          tippy: "tooltip",
        }
    end
  end
end
