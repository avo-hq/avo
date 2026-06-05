# frozen_string_literal: true

class Avo::Views::ResourceEditComponent < Avo::ResourceComponent
  include Avo::ApplicationHelper
  include Avo::Concerns::FormBuilder

  prop :resource
  prop :record
  prop :actions, default: [].freeze
  prop :view, default: Avo::ViewInquirer.new(:edit).freeze

  def title
    @resource.default_panel_name
  end

  def back_path
    # The `return_to` param takes precedence over anything else.
    return params[:return_to] if params[:return_to].present?

    return resource_view_path if via_resource?
    return resources_path if via_index?

    if is_edit? && Avo.configuration.resource_default_view.show? # via resource show or edit page
      return helpers.resource_path(record: @resource.record, resource: @resource, **keep_referrer_params)
    end

    resources_path
  end

  def resources_path
    helpers.resources_path(resource: @resource, **keep_referrer_params)
  end

  def resource_view_path
    helpers.resource_view_path(record: association_resource.record, resource: association_resource)
  end

  def can_see_the_destroy_button?
    return super if is_edit? && Avo.configuration.resource_default_view.edit?

    false
  end

  # The save button is dependent on the edit? policy method.
  # The update? method should be called only when the user clicks the Save button so the developer gets access to the params from the form.
  def can_see_the_save_button?
    @resource.authorization.authorize_action @view, raise_exception: false
  end

  def controls
    @resource.render_edit_controls
  end

  # True when the form is shown inside a modal opened from a belongs_to
  # "Create new" link. In that case the title moves to the modal header and the
  # controls move to the modal footer, so the in-form panel header is skipped.
  def embedded_in_modal?
    params[:via_belongs_to_resource_class].present?
  end

  # Renders the form panels. When embedded in a modal the panel header is
  # dropped — its title and controls live in the modal chrome instead.
  def render_form_items(form)
    items = @resource.get_items
    items = items.reject(&:is_header?) if embedded_in_modal?

    safe_join(items.each_with_index.map do |item, index|
      render Avo::Items::SwitcherComponent.new(
        resource: @resource,
        reflection: @reflection,
        item: item,
        index: index + 1,
        view: @view,
        parent_resource: @parent_resource,
        parent_record: @parent_record,
        form: form,
        parent_component: self,
        actions: @actions
      )
    end)
  end

  private

  def via_index?
    params[:via_view] == "index"
  end

  def is_edit?
    @view.in?(%w[edit update])
  end
end
