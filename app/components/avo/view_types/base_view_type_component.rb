class Avo::ViewTypes::BaseViewTypeComponent < Avo::BaseComponent
  extend PropInitializer::Properties

  prop :resources
  prop :resource
  prop :reflection
  prop :parent_record
  prop :parent_resource
  prop :actions, reader: :public
  prop :pagy
  prop :query
  prop :turbo_frame
  prop :index_params

  def list_frame_id
    "#{resource_name_for(@resource)}_list"
  end

  def paginator_component
    Avo::PaginatorComponent.new(
      pagy: @pagy,
      turbo_frame: @turbo_frame,
      index_params: @index_params,
      resource: @resource,
      parent_record: @parent_record,
      parent_resource: @parent_resource,
      discreet_pagination: field&.discreet_pagination,
      field_per_page: field&.per_page
    )
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

  def encrypted_query
    # A page cut by its source is all that is held, so there is nothing to select across pages
    return :select_all_disabled if @query.is_a?(Avo::Resources::ArrayResource::Page)

    # TODO: move this to the resource where we can apply the adapter pattern
    if Module.const_defined?("Ransack::Search") && @query.instance_of?(Ransack::Search)
      @query = @query.result
    end

    Avo::Services::EncryptionService.encrypt(message: @query, purpose: :select_all, serializer: Marshal)
  rescue
    disable_select_all
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
