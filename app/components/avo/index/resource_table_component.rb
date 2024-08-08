# frozen_string_literal: true

class Avo::Index::ResourceTableComponent < Avo::BaseComponent
  include Avo::ApplicationHelper
  attr_reader :pagy, :query

  def before_render
    @header_fields, @table_row_components = cache_table_rows
  end

  # NOTE through reflection breaks ./spec/features/avo/has_many_field_spec.rb
  #
  # prop :resources, _Nilable(_Array(Avo::BaseResource))
  # prop :resource, _Nilable(Avo::BaseResource)
  # prop :reflection, _Nilable(ActiveRecord::Reflection::AssociationReflection)
  # prop :reflection, _Nilable(ActiveRecord::Reflection::ThroughReflection)
  # prop :parent_record, _Nilable(ActiveRecord::Base)
  # prop :parent_resource, _Nilable(Avo::BaseResource), reader: :public
  # prop :pagy, _Nilable(Pagy), reader: :public
  # prop :query, _Nilable(ActiveRecord::Relation), reader: :public
  # prop :actions, _Nilable(_Array(Avo::BaseAction)), reader: :public
  def initialize(resources: nil, resource: nil, reflection: nil, parent_record: nil, parent_resource: nil, pagy: nil, query: nil, actions: nil)
    @resources = resources
    @resource = resource
    @reflection = reflection
    @parent_record = parent_record
    @parent_resource = parent_resource
    @pagy = pagy
    @query = query
    @actions = actions
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

  def cache_table_rows
    # Cache the execution of the following block if caching is enabled in Avo configuration
    cache_if Avo.configuration.cache_resources_on_index_view, @resource.cache_hash(@parent_record), expires_in: 1.day do
      header_fields, table_row_components = generate_table_row_components

      # Create an array of header field labels used for each row to render values on the right column
      header_fields_ids = header_fields.map(&:table_header_label)

      # Assign header field IDs to each TableRowComponent
      # We assign it here because only complete header fields array after last table row.
      table_row_components.map { |table_row_component| table_row_component.header_fields = header_fields_ids }

      # Return header fields and table row components
      return [header_fields, table_row_components]
    end
  end

  def generate_table_row_components
    # Initialize arrays to hold header fields and table row components
    header_fields = []
    table_row_components = []

    # Loop through each resource in @resources
    @resources.each do |resource|
      # Get fields for the current resource and concat them to the @header_fields
      row_fields = resource.get_fields(reflection: @reflection, only_root: true)
      header_fields.concat row_fields

      # Create a TableRowComponent instance for the resource and add it to @table_row_components
      table_row_components << Avo::Index::TableRowComponent.new(
        resource: resource,
        fields: row_fields,
        reflection: @reflection,
        parent_record: @parent_record,
        parent_resource: @parent_resource,
        actions: @actions
      )
    end

    # Remove duplicate header fields based on table_header_label
    header_fields.uniq!(&:table_header_label)

    [header_fields, table_row_components]
  end
end
