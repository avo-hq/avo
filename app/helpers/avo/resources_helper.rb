module Avo
  module ResourcesHelper
    def resource_table(resources, resource)
      render partial: 'avo/partials/resource_table', locals: {
        resources: resources,
        resource: resource,
      }
    end

    def resource_grid(resources, resource)
      render partial: 'avo/partials/resource_grid', locals: {
        resources: resources,
        resource: resource,
      }
    end

    def index_field(field, index, resource)
      if Object.const_defined? field.component_name(:index)
        render field.component_name(:index).safe_constantize.new(field: field, resource: resource, index: index)
      else
        render partial: field.partial_path_for(:index), locals: {
          field: field,
          index: index,
          resource: resource,
        }
      end
    end

    def show_field(field, index, resource)
      if Object.const_defined? field.component_name(:show)
        render field.component_name(:show).safe_constantize.new(field: field, resource: resource, index: index)
      else
        render partial: field.partial_path_for(:show), locals: {
          field: field,
          index: index,
          resource: resource,
        }
      end
    end

    def edit_field(field, index, resource, form, displayed_in_modal: false)
      render partial: field.partial_path_for(:edit), locals: {
        field: field,
        index: index,
        resource: resource,
        form: form,
        displayed_in_modal: displayed_in_modal,
      }
    end

    def index_field_wrapper(dash_if_blank: true, field: nil, class: '', **args, &block)
      # response = "<td class='px-4 py-2 leading-tight whitespace-no-wrap h-12 #{args[:class]}' data-field-id='#{field.id}'>"
      # if field.value.blank? and dash_if_blank
      #   response += '—'
      # else
      #   response += block.call.to_s
      # end
      # response += '</td>'
      # return response.html_safe
      render Index::FieldWrapperComponent.new(dash_if_blank: dash_if_blank, field: field, classes: args[:class], **args) do
        capture(&block)
      end
    end

    def show_field_wrapper(dash_if_blank: true, field: {}, index: nil, displayed_in_modal: false, full_width: false, **args, &block)
      classes = args[:class].present? ? args[:class] : ''

      if index != 0 or displayed_in_modal
        classes += ' border-t'
      end

      render layout: 'layouts/avo/show_field_wrapper', locals: {
        classes: classes,
        field: field,
        dash_if_blank: dash_if_blank,
        full_width: full_width,
        } do
        capture(&block)
      end
    end

    def edit_field_wrapper(dash_if_blank: true, field: {}, index: nil, displayed_in_modal: false, full_width: false, form: nil, **args, &block)
      classes = args[:class].present? ? args[:class] : ''

      if index != 0 or displayed_in_modal
        classes += ' border-t'
      end

      render layout: 'layouts/avo/edit_field_wrapper', locals: {
        classes: classes,
        field: field,
        dash_if_blank: dash_if_blank,
        form: form,
        displayed_in_modal: displayed_in_modal,
        full_width: full_width,
      } do
        capture(&block)
      end
    end

    def filter_wrapper(name: nil, index: nil, **args, &block)
      render layout: 'layouts/avo/filter_wrapper', locals: {
        name: name,
        index: index,
      } do
        capture(&block)
      end
    end

    def item_selector_init(resource)
      "data-resource-name='#{resource.plural_name.downcase}' data-resource-id='#{resource.model.id}' data-controller='item-selector'"
    end

    def item_selector_input(floating: false, size: :md)
      "<input type='checkbox'
        class='mx-3 #{'absolute inset-auto left-0 mt-2 z-10 hidden group-hover:block checked:block' if floating} #{size.to_sym == :lg ? 'w-5 h-5' : 'w-4 h-4'}'
        data-action='input->item-selector#toggle'
      />"
    end
  end
end
