# frozen_string_literal: true

class Avo::Index::ResourceTableComponent < ViewComponent::Base
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
