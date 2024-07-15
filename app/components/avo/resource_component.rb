class Avo::ResourceComponent < Avo::BaseComponent
  include Avo::Concerns::ChecksAssocAuthorization
  include Avo::Concerns::RequestMethods

  attr_reader :fields_by_panel
  attr_reader :has_one_panels
  attr_reader :has_many_panels
  attr_reader :has_as_belongs_to_many_panels
  attr_reader :resource_tools
  attr_reader :resource
  attr_reader :view

  def can_create?
    return authorize_association_for(:create) if @reflection.present?

    @resource.authorization.authorize_action(:create, raise_exception: false)
  end

  def can_delete?
    return authorize_association_for(:destroy) if @reflection.present?

    @resource.authorization.authorize_action(:destroy, raise_exception: false)
  end

  def can_detach?
    return false if @reflection.blank? || @resource.record.blank? || !authorize_association_for(:detach)

    # If the inverse_of is a belongs_to, we need to check if it's optional in order to know if we can detach it.
    if inverse_of[:type].eql?(ActiveRecord::Reflection::BelongsToReflection)
      inverse_of[:optional]
    else
      true
    end
  end

  def detach_path
    return "/" if @reflection.blank?

    helpers.resource_detach_path(params[:resource_name] || params[:via_relation], params[:via_record_id] || params[:id], @reflection.name.to_s, @resource.record.to_param)
  end

  def can_see_the_edit_button?
    return authorize_association_for(:edit) if @reflection.present?

    @resource.authorization.authorize_action(:edit, raise_exception: false)
  end

  def can_see_the_destroy_button?
    @resource.authorization.authorize_action(:destroy, raise_exception: false)
  end

  def can_see_the_actions_button?
    return false if @actions.blank?

    return authorize_association_for(:act_on) if @reflection.present?

    @resource.authorization.authorize_action(:act_on, raise_exception: false) && !has_reflection_and_is_read_only
  end

  def destroy_path
    args = {record: @resource.record, resource: @resource}

    if is_associated_record?
      args[:via_resource_class] = params[:via_resource_class]
      args[:via_relation_class] = params[:via_relation_class]
      args[:via_relation] = params[:via_relation]
      args[:via_record_id] = params[:via_record_id]
      args.compact!
    end

    args[:referrer] = if params[:via_resource_class].present?
      back_path
    # If we're deleting a resource from a parent resource, we need to go back to the parent resource page after the deletion
    elsif @parent_resource.present?
      helpers.resource_path(record: @parent_record, resource: @parent_resource)
    end

    helpers.resource_path(**args)
  end

  def main_panel
    @main_panel ||= @resource.get_items.find do |item|
      item.is_main_panel?
    end
  end

  def sidebars
    return [] if Avo.license.lacks_with_trial(:resource_sidebar)

    @sidebars ||= @item.items
      .select do |item|
        item.is_sidebar?
      end
      .map do |sidebar|
        sidebar.hydrate(view: view, resource: resource)
      end
  end

  def has_reflection_and_is_read_only
    if @reflection.present? && @reflection.active_record.name && @reflection.name
      resource = Avo.resource_manager.get_resource_by_model_class(@reflection.active_record.name).new(params: helpers.params, view: view, user: helpers._current_user)
      fields = resource.get_field_definitions
      filtered_fields = fields.filter { |f| f.id == @reflection.name }
    else
      return false
    end

    if filtered_fields.present?
      filtered_fields.find { |f| f.id == @reflection.name }.is_disabled?
    else
      false
    end
  end

  def render_control(control)
    send :"render_#{control.type}", control
  end

  def render_cards_component
    if Avo.plugin_manager.installed?("avo-dashboards")
      render Avo::CardsComponent.new cards: @resource.detect_cards.visible_cards, classes: "pb-4 sm:grid-cols-3"
    end
  end

  private

  def via_resource?
    (params[:via_resource_class].present? || params[:via_relation_class].present?) && params[:via_record_id].present?
  end

  def keep_referrer_params
    {page: referrer_params["page"]}.compact
  end

  def render_back_button(control)
    return if back_path.blank? || (is_a_related_resource? && !via_resource?)

    tippy = control.title ? :tooltip : nil
    a_link back_path,
      style: :text,
      title: control.title,
      data: {tippy: tippy},
      icon: "heroicons/outline/arrow-left" do
      control.label
    end
  end

  def render_actions_list(actions_list)
    return unless can_see_the_actions_button?

    render Avo::ActionsComponent.new(
      actions: @actions,
      resource: @resource,
      view: @view,
      exclude: actions_list.exclude,
      include: actions_list.include,
      style: actions_list.style,
      color: actions_list.color,
      label: actions_list.label,
      size: actions_list.size,
      icon: actions_list.icon,
      as_row_control: instance_of?(Avo::Index::ResourceControlsComponent)
    )
  end

  def render_delete_button(control)
    # If the resource is a related resource, we use the can_delete? policy method because it uses
    # authorize_association_for(:destroy).
    # Otherwise we use the can_see_the_destroy_button? policy method becuse it do no check for assiciation
    # only for authorize_action .
    policy_method = is_a_related_resource? ? :can_delete? : :can_see_the_destroy_button?
    return unless send policy_method

    a_link destroy_path,
      style: :text,
      color: :red,
      icon: "avo/trash",
      form_class: "flex flex-col sm:flex-row sm:inline-flex",
      title: control.title,
      aria_label: control.title,
      data: {
        turbo_confirm: t("avo.are_you_sure", item: @resource.record.model_name.name.downcase),
        turbo_method: :delete,
        target: "control:destroy",
        control: :destroy,
        tippy: control.title ? :tooltip : nil,
        "resource-id": @resource.record.id,
      } do
      control.label
    end
  end

  def render_save_button(control)
    return unless can_see_the_save_button?

    a_button color: :primary,
      style: :primary,
      loading: true,
      type: :submit,
      icon: "avo/save" do
      control.label
    end
  end

  def render_edit_button(control)
    return unless can_see_the_edit_button?

    a_link edit_path,
      color: :primary,
      style: :primary,
      title: control.title,
      data: {tippy: control.title ? :tooltip : nil},
      icon: "avo/edit" do
      control.label
    end
  end

  def render_detach_button(control)
    return unless is_a_related_resource? && can_detach?

    a_link detach_path,
      icon: "avo/detach",
      form_class: "flex flex-col sm:flex-row sm:inline-flex",
      style: :text,
      data: {
        turbo_method: :delete,
        turbo_confirm: "Are you sure you want to detach this #{title}."
      } do
      control.label || t("avo.detach_item", item: title).humanize
    end
  end

  def render_create_button(control)
    return unless can_see_the_create_button?

    a_link create_path,
      color: :primary,
      style: :primary,
      icon: "heroicons/outline/plus",
      data: {
        target: :create
      } do
      control.label
    end
  end

  def render_attach_button(control)
    return unless can_attach?

    a_link attach_path,
      icon: "heroicons/outline/link",
      color: :primary,
      style: :text,
      data: {
        turbo_frame: :attach_modal,
        target: :attach
      } do
      control.label
    end
  end

  def render_link_to(link)
    a_link link.path,
      color: link.color,
      style: link.style,
      icon: link.icon,
      icon_class: link.icon_class,
      title: link.title, target: link.target,
      class: link.classes,
      size: link.size,
      data: {
        **link.data,
        tippy: link.title ? :tooltip : nil,
      } do
      link.label
    end
  end

  def render_action(action)
    return if !can_see_the_actions_button?
    return if !action.action.visible_in_view(parent_resource: @parent_resource)

    a_link action.path,
      color: action.color,
      style: action.style,
      icon: action.icon,
      icon_class: action.icon_class,
      title: action.title,
      size: action.size,
      data: {
        turbo_frame: Avo::ACTIONS_TURBO_FRAME_ID,
        action_name: action.action.action_name,
        tippy: action.title ? :tooltip : nil,
        action: "click->actions-picker#visitAction",
      } do
      action.label
    end
  end

  def is_a_related_resource?
    @reflection.present? && @resource.record.present?
  end

  def inverse_of
    @inverse_of ||= begin
      inverse_of = Avo.associations_information[@parent_record.class.name][@reflection.name.to_sym][:inverse_of]

      if inverse_of.blank? && Rails.env.development?
        Avo.error_manager.add({
          url: "https://docs.avohq.io/3.0/upgrade.html#upgrade-from-3-7-4-to-3-9-1",
          target: "_blank",
          # Ex: Please configure the 'inverse_of' option for the ':users' association on the 'Project' model.
          message: "Avo uses the 'inverse_of' option to determine the inverse association and figure out if the association permit or not detaching.\n\r
                    Please configure the 'inverse_of' option for the '#{current_reflection.macro} :#{current_reflection.name}' association on the '#{current_reflection.active_record.name}' model.\n\r
                    Otherwise the detach button will be visible by default."
        })
      end

      inverse_of
    end
  end
end
