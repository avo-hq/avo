# frozen_string_literal: true

class Avo::ActionsComponent < Avo::BaseComponent
  include Avo::ApplicationHelper

  prop :as_row_control, default: false
  # True only for actions buttons inside an index table row, whose hotkey must be
  # managed by the index-row-navigator (emitted as data-hotkey-original). Page-level
  # header buttons (index/show/edit) use a plain data-hotkey instead.
  prop :as_index_row_control, default: false
  prop :icon
  prop :icon_class
  prop :size, default: :md
  prop :title
  prop :color
  prop :include, default: [].freeze do |include|
    Array(include).to_set
  end
  prop :custom_list, default: false
  prop :label do |label|
    if @custom_list
      label
    else
      label || I18n.t("avo.actions")
    end
  end
  prop :style, default: :primary
  prop :actions, default: [].freeze
  prop :exclude, default: [].freeze do |exclude|
    Array(exclude).to_set
  end
  prop :resource
  prop :view
  prop :host_component
  prop :hotkey

  delegate_missing_to :@host_component

  def after_initialize
    filter_actions unless @custom_list

    # Hydrate each action action with the record when rendering a list on row controls
    if @as_row_control
      @actions.each do |action|
        action.hydrate(resource: @resource, record: @resource.record) if action.respond_to?(:hydrate)
      end
    end
  end

  def render?
    @actions.present?
  end

  def filter_actions
    @actions = @actions.dup

    if @exclude.any?
      @actions.reject! { |action| @exclude.include?(action.class) }
    end

    if @include.any?
      @actions.select! { |action| @include.include?(action.class) }
    end
  end

  private

  def icon(icon)
    helpers.svg icon, class: "h-5 shrink-0 me-1 inline pointer-events-none"
  end

  def render_item(action)
    case action
    when Avo::Divider
      render Avo::DividerComponent.new(action.label)
    when Avo::BaseAction
      render_action_link(action)
    when defined?(Avo::CustomControls::Resources::Controls::Action) && Avo::CustomControls::Resources::Controls::Action
      render_action_link(action.action, icon: action.icon)
    when defined?(Avo::CustomControls::Resources::Controls::LinkTo) && Avo::CustomControls::Resources::Controls::LinkTo
      # Dropdown items render as plain links, not ButtonComponents, so the styling
      # options have nothing to land in — spreading the raw kwargs leaked them into
      # the markup (color: :fuchsia rendered as color="fuchsia"). Excluding
      # CONTROL_OPTIONS drops those and the internal plumbing while still forwarding
      # genuine HTML attributes like rel:.
      link_to action.path,
        **action.args.except(*Avo::Resources::Controls::BaseControl::CONTROL_OPTIONS),
        class: action.classes,
        title: action.title,
        target: action.target,
        data: action.data do
          raw("#{icon(action.icon)} #{action.label}")
        end
    end
  end

  private

  def render_action_link(action, icon: nil)
    link_to action.link_arguments(resource: @resource, arguments: action.arguments).first,
      data: action_data_attributes(action),
      title: action.action_name,
      class: action_css_class(action),
      # Keep disabled actions out of the tab order and announce their state.
      # The href stays put: item_selector_controller reads it to toggle actions.
      tabindex: (-1 if action.disabled?),
      aria: {disabled: action.disabled?} do
        raw("#{icon(icon || action.icon)} #{action.action_name}")
      end
  end

  def action_data_attributes(action)
    {
      action_name: action.action_name,
      "turbo-frame": Avo::MODAL_FRAME_ID,
      action: "click->actions-picker#visitAction",
      "actions-picker-target": action.standalone ? "standaloneAction" : "resourceAction",
      disabled: action.disabled?,
      turbo_prefetch: false,
      disabled_classes: "dropdown-menu__item--disabled",
      resource_name: action.resource.model_key
    }
  end

  def action_css_class(action)
    helpers.class_names("", {
      "dropdown-menu__item--disabled": action.disabled?,
      "": action.enabled?,
    })
  end
end
