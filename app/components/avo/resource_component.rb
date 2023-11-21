class Avo::ResourceComponent < Avo::BaseComponent
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
    if inverse_of.is_a?(ActiveRecord::Reflection::BelongsToReflection)
      inverse_of.options[:optional]
    else
      true
    end
  end

  def detach_path
    return "/" if @reflection.blank?

    helpers.resource_detach_path(params[:resource_name], params[:id], @reflection.name.to_s, @resource.record.to_param)
  end

  def can_see_the_edit_button?
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

    args[:referrer] = if params[:via_resource_class].present?
      back_path
    # If we're deleting a resource from a parent resource, we need to go back to the parent resource page after the deletion
    elsif @parent_resource.present?
      helpers.resource_path(record: @parent_record, resource: @parent_resource)
    end

    helpers.resource_path(**args)
  end

  # Ex: A Post has many Comments
  def authorize_association_for(policy_method)
    policy_result = true

    if @reflection.present?
      # Fetch the appropiate resource
      reflection_resource = field.resource
      # Fetch the record
      # Hydrate the resource with the record if we have one
      reflection_resource.hydrate(record: @parent_record) if @parent_record.present?
      # Use the related_name as the base of the association
      association_name = @reflection.name

      if association_name.present?
        method_name = "#{policy_method}_#{association_name}?".to_sym

        # Use the policy methods from the parent (Post)
        service = reflection_resource.authorization

        if service.has_method?(method_name, raise_exception: false)
          # Some policy methods should get the parent record in order to have the necessarry information to do the authorization
          # Example: Post->has_many->Comments
          #
          # When you want to authorize the creation/attaching of a Comment, you don't have the Comment instance.
          # But you do have the Post instance and you can get that in your policy to authorize against.
          parent_policy_methods = [:view, :create, :attach, :act_on]

          record = if parent_policy_methods.include?(policy_method)
            # Use the parent record (Post)
            reflection_resource.record
          else
            # Override the record with the child record (Comment)
            resource.record
          end
          policy_result = service.authorize_action(method_name, record: record, raise_exception: false)
        end
      end
    end

    policy_result
  end

  def main_panel
    @resource.get_items.find do |item|
      item.is_main_panel?
    end
  end

  def sidebars
    return if Avo.license.lacks_with_trial(:resource_sidebar)

    @item.items.select do |item|
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
    send "render_#{control.type}", control
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

  def render_back_button(control)
    return if back_path.blank? || is_a_related_resource?

    tippy = control.title ? :tooltip : nil
    a_link back_path,
      style: :text,
      title: control.title,
      data: {tippy: tippy},
      icon: "arrow-left" do
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
      icon: "trash",
      form_class: "flex flex-col sm:flex-row sm:inline-flex",
      title: control.title,
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
      icon: "save" do
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
      icon: "edit" do
      control.label
    end
  end

  def render_detach_button(control)
    return unless is_a_related_resource? && can_detach?

    a_button url: detach_path,
      icon: "detach",
      method: :delete,
      form_class: "flex flex-col sm:flex-row sm:inline-flex",
      style: :text,
      data: {
        confirm: "Are you sure you want to detach this #{title}."
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
        turbo_frame: "actions_show",
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
    current_reflection = @reflection.active_record.reflect_on_all_associations.find do |reflection|
      reflection.name == @reflection.name.to_sym
    end

    inverse_of = current_reflection.inverse_of

    if inverse_of.blank? && Rails.env.development?
      puts "WARNING! Avo uses the 'inverse_of' option to determine the inverse association and figure out if the association permit or not detaching."
      # Ex: Please configure the 'inverse_of' option for the ':users' association on the 'Project' model.
      puts "Please configure the 'inverse_of' option for the '#{current_reflection.macro} :#{current_reflection.name}' association on the '#{current_reflection.active_record.name}' model."
      puts "Otherwise the detach button will be visible by default.\n\n"
    end

    inverse_of
  end
end
