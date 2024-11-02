class Avo::ComboboxResultsController < Avo::ApplicationController
  def show
    # find resource
    resource_class = Avo.resource_manager.get_resource(params[:resource_class])
    resource = resource_class.new(params: params, view: :edit, user: Avo::Current.user).tap do |r|
      r.detect_fields
    end

    # find field
    field = resource.get_fields.find { |f| f.is_a?(Avo::Fields::ComboboxField) && f.id.to_sym == params[:field_id].to_sym }

    # get query
    query = field.query

    # run query in the execution context
    @results = Avo::ExecutionContext.new(
      target: query,
      resource: resource,
      field: field,
      params: params,
      q: params[:q]
    ).handle

    render turbo_stream: helpers.async_combobox_options(@results)
  end
end
