# frozen_string_literal: true

class Avo::ViewTypes::TableComponent < Avo::ViewTypes::BaseViewTypeComponent
  include Avo::ApplicationHelper

  attr_reader :pagy, :query

  def before_render
    @header_fields, @table_row_components = generate_table_row_components
  end

  # ARIA grid affordances and the row-navigator binding are only added on
  # top-level index pages. On a parent record's show view (where @reflection
  # is present), the has-many table is not keyboard-navigable as a grid, so
  # the global Shift+T / j / k shortcuts find no target.
  def table_attrs
    return {} if @reflection.present?

    {
      tabindex: "0",
      role: "grid",
      "aria-label": @resource.plural_name,
      data: {"index-row-navigator-target": "table", "content-focus": ""}
    }
  end

  def encrypted_query
    # TODO: move this to the resource where we can apply the adapter pattern
    if Module.const_defined?("Ransack::Search") && @query.instance_of?(Ransack::Search)
      @query = @query.result
    end

    Avo::Services::EncryptionService.encrypt(message: @query, purpose: :select_all, serializer: Marshal)
  rescue
    disable_select_all
  end

  def selected_page_label
    if @resource.pagination_type.countless?
      t "avo.x_records_selected_from_page_html", selected: @pagy.in
    else
      t "avo.x_records_selected_from_a_total_of_x_html", selected: @pagy.in, count: @pagy.count
    end
  end

  def selected_all_label
    if @resource.pagination_type.countless?
      t "avo.records_selected_from_all_pages_html"
    else
      t "avo.x_records_selected_from_all_pages_html", count: @pagy.count
    end
  end

  # Table rows are not fragment-cached. A `cache_if` wrapped this until it was
  # removed: a `return` inside its block unwound past Action View's
  # `write_fragment`, so nothing was ever written, and a hit would have handed
  # back an HTML string where the components are expected. Caching the table per
  # row under `Avo::Resources::Base#index_cache_key`, as the grid view does, is a
  # follow-up.
  def generate_table_row_components
    # Initialize arrays to hold header fields and table row components
    header_fields = []
    table_row_components = []

    # Loop through each resource in @resources
    @resources.each_with_index do |resource, index|
      # Get fields for the current resource and concat them to the @header_fields
      row_fields = resource.get_fields(reflection: @reflection, only_root: true)
      header_fields.concat row_fields

      # Create a TableRowComponent instance for the resource and add it to @table_row_components
      table_row_components << resource.resolve_component(Avo::Index::TableRowComponent).new(
        resource: resource,
        fields: row_fields,
        reflection: @reflection,
        parent_record: @parent_record,
        parent_resource: @parent_resource,
        actions: @actions,
        index:
      )
    end

    # Remove duplicate header fields based on table_header_label
    header_fields.uniq!(&:table_header_label)

    # Every row renders its cells against the complete header, which is only
    # known once the last row's fields have been collected.
    header_fields_ids = header_fields.map(&:table_header_label)
    table_row_components.each { |table_row_component| table_row_component.header_fields = header_fields_ids }

    [header_fields, table_row_components]
  end

  private

  def disable_select_all
    if Rails.env.development?
      Avo.error_manager.add({
        url: "https://docs.avohq.io/4.0/select-all.html#serialization-known-issues",
        target: "_blank",
        message: "An error occurred while serializing the query object. The Select All feature has been disabled because it depends on successful query serialization. For more details and troubleshooting steps, click here."
      })
    end

    :select_all_disabled
  end
end
