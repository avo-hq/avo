module Avo
  module ResourcesHelper
    def resource_table(resources, resource)
      render partial: 'avo/resources/table', locals: {
        resources: resources,
        resource: resource,
      }
    end

    def resource_grid(resources, resource)
      render partial: 'avo/resources/grid', locals: {
        resources: resources,
        resource: resource,
      }
    end

    def index_field(field, index, resource)
      render partial: "avo/fields/index/#{field.component}", locals: {
        field: field,
        index: index,
        resource: resource,
      }
    end

    def show_field(field, index, resource)
      render partial: "avo/fields/show/#{field.component}", locals: {
        field: field,
        index: index,
        resource: resource,
      }
    end

    def edit_field(field, index, resource, form, displayed_in_modal: false)
      render partial: "avo/fields/edit/#{field.component}", locals: {
        field: field,
        index: index,
        resource: resource,
        form: form,
        displayed_in_modal: displayed_in_modal,
      }
    end

    def index_field_wrapper(dash_if_empty: true, field: {}, class: '', **args, &block)
      render layout: 'layouts/avo/index_field_wrapper', locals: {
        classes: args[:class],
        field: field,
        dash_if_empty: dash_if_empty,
      } do
        capture(&block)
      end
    end

    def show_field_wrapper(dash_if_empty: true, field: {}, index: nil, displayed_in_modal: false, full_width: false, **args, &block)
      classes = args[:class].present? ? args[:class] : ''

      if index != 0 or displayed_in_modal
        classes += ' border-t'
      end

      render layout: 'layouts/avo/show_field_wrapper', locals: {
        classes: classes,
        field: field,
        dash_if_empty: dash_if_empty,
        full_width: full_width,
        } do
        capture(&block)
      end
    end

    def edit_field_wrapper(dash_if_empty: true, field: {}, index: nil, displayed_in_modal: false, full_width: false, form: nil, **args, &block)
      classes = args[:class].present? ? args[:class] : ''

      if index != 0 or displayed_in_modal
        classes += ' border-t'
      end

      render layout: 'layouts/avo/edit_field_wrapper', locals: {
        classes: classes,
        field: field,
        dash_if_empty: dash_if_empty,
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
  end
end
