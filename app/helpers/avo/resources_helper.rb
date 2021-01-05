module Avo
  module ResourcesHelper
    def resource_table(resources)
      fields = resources.length > 0 ? resources.first[:fields] : []

      render partial: 'avo/resources/table', locals: {
        resources: resources,
        fields: fields,
      }
    end

    def index_field(field, index)
      partial_path = "avo/fields/index/#{field[:component]}"

      render partial: partial_path, locals: {
        field: field,
        index: index,
      }
    end

    def show_field(field, index)
      partial_path = "avo/fields/show/#{field[:component]}"

      render partial: partial_path, locals: {
        field: field,
        index: index,
      }
    end

    def index_field_wrapper(dash_if_empty: true, **args, &block)
      classes = args[:class].present? ? args[:class] : ''
      field = args[:field].present? ? args[:field] : ''

      render layout: 'layouts/avo/index_field_wrapper', locals: {
        classes: classes,
        field: field,
        dash_if_empty: dash_if_empty,
      } do
        capture(&block)
      end
    end

    def item_controls(resource)
      render partial: 'avo/resources/item_controls', locals: {
        resource: resource,
      }
    end
  end
end
