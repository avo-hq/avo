# frozen_string_literal: true

module Avo
  # :nodoc:
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
      "data-resource-name='#{resource.model_key}' data-resource-id='#{resource.model.id}' data-controller='item-selector'"
    end

    def item_selector_input(floating: false, size: :md)
      tag :input,
        type: "checkbox",
        name: t("avo.select_item"),
        title: t("avo.select_item"),
        class: "mx-3 rounded checked:bg-primary-400 focus:checked:!bg-primary-400 #{floating ? "absolute inset-auto left-0 mt-3 z-10 hidden group-hover:block checked:block" : ""} #{size.to_sym == :lg ? "w-5 h-5" : "w-4 h-4"}",
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
        class: "mx-3 rounded w-4 h-4 checked:bg-primary-400 focus:checked:!bg-primary-400",
        data: {
          action: "input->item-select-all#toggle",
          item_select_all_target: "checkbox",
          tippy: "tooltip",
        }
    end

    def map_view_table_layout_class(resource_map_options)
      case resource_map_options.dig(:table, :layout)
      when :left
        'table-left'
      when :bottom
        'table-bottom'
      when :top
        'table-top'
      else
        'table-right'
      end
    end

    def render_map_view_table?(resource_map_options)
      resource_map_options.dig(:table, :visible)
    end

    def resource_location_markers(resources, map_options)
      # If we have no proc and no default location method, don't try to create markers
      return [] if map_options[:record_marker].blank? && !resources.first.record.respond_to?(:coordinates)

      marker_proc = map_options[:record_marker] || default_record_marker_proc

      resources.map do |resource|
        coordinates = marker_proc.call(record: resource.record)

        next unless coordinates[:latitude].present? && coordinates[:longitude].present?

        coordinates
      end.compact
    end

    def resource_mapkick_options(map_options)
      return {} unless map_options.present?

      map_options[:mapkick_options] || {}
    end

    private

    def default_record_marker_proc
      lambda { |record:|
        {
          latitude: record.coordinates.first,
          longitude: record.coordinates.last
        }
      }
    end
  end
end
