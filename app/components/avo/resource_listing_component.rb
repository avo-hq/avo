class Avo::ResourceListingComponent < Avo::BaseComponent
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

  def paginator_component
    Avo::PaginatorComponent.new(
      pagy: @pagy,
      turbo_frame: @turbo_frame,
      index_params: @index_params,
      resource: @resource,
      parent_record: @parent_record,
      parent_resource: @parent_resource,
      discreet_pagination: field&.discreet_pagination
    )
  end
end
