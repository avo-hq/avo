# frozen_string_literal: true

class Avo::ActionsComponent < Avo::BaseComponent
  include Avo::ApplicationHelper

  ACTION_FILTER = _Set(_Class(Avo::BaseAction))

  prop :as_row_control, default: false
  prop :icon
  prop :size, default: :md
  prop :title
  prop :color do |value|
    value || :primary
  end
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
  prop :style, default: :outline
  prop :actions, default: [].freeze
  prop :exclude, default: [].freeze do |exclude|
    Array(exclude).to_set
  end
  prop :resource
  prop :view
  prop :host_component

  delegate_missing_to :@host_component

  def after_initialize
    filter_actions unless @custom_list
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

  # How should the action be displayed by default
  def is_disabled?(action)
    return false if action.standalone || @as_row_control

    on_index_page?
  end

  private

  def on_record_page?
    @view.in?(["show", "edit", "new"])
  end

  def on_index_page?
    !on_record_page?
  end

  def icon(icon)
    svg icon, class: "h-5 shrink-0 mr-1 inline pointer-events-none"
  end

  def render_item(action)
    case action
    when Avo::Divider
      render_divider(action)
    when Avo::BaseAction
      render_action_link(action)
    when defined?(Avo::Advanced::Resources::Controls::Action) && Avo::Advanced::Resources::Controls::Action
      render_action_link(action.action, icon: action.icon)
    when defined?(Avo::Advanced::Resources::Controls::LinkTo) && Avo::Advanced::Resources::Controls::LinkTo
      link_to action.args[:path],
        class: action.args.delete(:class) || "flex items-center px-4 py-3 w-full text-black font-semibold text-sm hover:bg-primary-100",
        **action.args.except(:path, :label, :icon) do
          raw("#{icon(action.args[:icon])} #{action.args[:label]}")
        end
    end
  end

  private

  def render_divider(action)
    label = action.label.is_a?(Hash) ? action.label[:label] : nil
    render Avo::DividerComponent.new(label)
  end

  def render_action_link(action, icon: nil)
    link_to action.link_arguments(resource: @resource, arguments: action.arguments).first,
      data: action_data_attributes(action),
      title: action.action_name,
      class: action_css_class(action) do
        raw("#{icon(icon || action.icon)} #{action.action_name}")
      end
  end

  def action_data_attributes(action)
    {
      action_name: action.action_name,
      "turbo-frame": Avo::MODAL_FRAME_ID,
      action: "click->actions-picker#visitAction",
      "actions-picker-target": action.standalone ? "standaloneAction" : "resourceAction",
      disabled: is_disabled?(action),
      turbo_prefetch: false,
    }
  end

  def action_css_class(action)
    helpers.class_names("flex items-center px-4 py-3 w-full font-semibold text-sm hover:bg-primary-100", {
      "text-gray-500": is_disabled?(action),
      "text-black": !is_disabled?(action),
    })
  end
end
