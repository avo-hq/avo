class Avo::ResourceListingComponent < Avo::BaseComponent
  include Avo::RendersViewSlots

  prop :resources
  prop :resource
  prop :reflection
  prop :parent_record
  prop :parent_resource
  prop :pagy
  prop :query
  prop :actions
  prop :turbo_frame
  prop :index_params

  def specific_view_component
    Avo.view_type_manager.component_for(@resource.view_type)
  end

  # A resource with `index_refresh_every` reloads this list on a timer. The URL is the request that rendered it
  # (the page, the association panel's frame or the last search), so a reload keeps the search, filters, sorting
  # and page the user is looking at.
  def refresh_data_attributes
    interval = @resource.index_refresh_interval(parent_record: @parent_record, parent_resource: @parent_resource)
    return {} if interval.nil?

    {
      controller: "resource-refresh",
      resource_refresh_url_value: request.fullpath,
      resource_refresh_interval_value: interval
    }
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
end
