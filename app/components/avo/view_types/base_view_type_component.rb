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
