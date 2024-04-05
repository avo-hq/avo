# frozen_string_literal: true

class Avo::Index::ResourceTableComponent < Avo::BaseComponent
  include Avo::ApplicationHelper
  attr_reader :pagy, :query

  def initialize(resources: nil, resource: nil, reflection: nil, parent_record: nil, parent_resource: nil, pagy: nil, query: nil, actions: nil)
    @resources = resources
    @resource = resource
    @reflection = reflection
    @parent_record = parent_record
    @parent_resource = parent_resource
    @pagy = pagy
    @query = query
    @actions = actions

    cache_if Avo.configuration.cache_resources_on_index_view, resource.cache_hash(parent_record), expires_in: 1.day do
      # Keep unique header fields, builded by joining all row visible fields.
      @header_fields = []

      # Rows keep each Avo::Index::TableRowComponent initialized to be rendered
      # It is initialized here in order to know what fields are visible to render them as column on header.
      @rows = @resources.map do |resource|
        # Store each row visible fields on @header_fields variable
        @header_fields.concat row_fields = resource.get_fields(reflection: reflection, only_root: true)

        {
          resource: resource,
          fields: row_fields,
          reflection: reflection,
          parent_record: parent_record,
          parent_resource: parent_resource,
          actions: actions
        }
      end

      # Render only uniq fields on header
      @header_fields.uniq! { |field| field.id }
    end
  end

  def encrypted_query
    # TODO: move this to the resource where we can apply the adapter pattern
    if Module.const_defined?("Ransack::Search") && query.instance_of?(Ransack::Search)
      @query = @query.result
    end

    Avo::Services::EncryptionService.encrypt(message: @query, purpose: :select_all, serializer: Marshal)
  end

  def selected_page_label
    if @resource.pagination_type.countless?
      t "avo.x_records_selected_from_page_html", selected: pagy.in
    else
      t "avo.x_records_selected_from_a_total_of_x_html", selected: pagy.in, count: pagy.count
    end
  end

  def selected_all_label
    if @resource.pagination_type.countless?
      t "avo.records_selected_from_all_pages_html"
    else
      t "avo.x_records_selected_from_all_pages_html", count: pagy.count
    end
  end
end
