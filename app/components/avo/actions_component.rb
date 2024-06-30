# frozen_string_literal: true

class Avo::ActionsComponent < Avo::BaseComponent
  include Avo::ApplicationHelper

  ACTION_FILTER = _Set(_Class(Avo::BaseAction))

  prop :actions, _Array(Avo::BaseAction), default: -> { [] }
  prop :resource, _Nilable(Avo::BaseResource)
  prop :view, _Nilable(Symbol), &:to_sym
  prop :exclude, _Nilable(ACTION_FILTER), &:to_set
  prop :include, _Nilable(ACTION_FILTER), &:to_set
  prop :style, Avo::ButtonComponent::STYLE, default: :outline
  prop :color, Symbol, default: :primary
  prop :label, String do |value|
    value || I18n.t("avo.actions")
  end
  prop :size, Avo::ButtonComponent::SIZE, default: :md
  prop :as_row_control, _Boolean, default: false
  prop :icon, _Nilable(String)

  def after_initialize
    filter_actions
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

  # When running an action for one record we should do it on a special path.
  # We do that so we get the `record` param inside the action so we can prefill fields.
  def action_path(action)
    return single_record_path(action) if @as_row_control
    return many_records_path(action) unless @resource.has_record_id?

    if on_record_page?
      single_record_path action
    else
      many_records_path action
    end
  end

  # How should the action be displayed by default
  def is_disabled?(action)
    return false if action.standalone || @as_row_control

    on_index_page?
  end

  private

  def on_record_page?
    @view.in?(%w[show edit new])
  end

  def on_index_page?
    !on_record_page?
  end

  def single_record_path(action)
    action_url(action, @resource.record_path)
  end

  def many_records_path(action)
    action_url(action, @resource.records_path)
  end

  def action_url(action, path)
    Avo::Services::URIService.parse(path)
      .append_paths("actions")
      .append_query(
        {
          action_id: action.to_param,
          arguments: Avo::BaseAction.encode_arguments(action.arguments)
        }.compact
      ).to_s
  end

  def icon(action)
    svg action.icon, class: "h-5 shrink-0 mr-1 inline pointer-events-none"
  end

  def render_item(action)
    case action
    when Avo::Divider
      render_divider(action)
    when Avo::BaseAction
      render_action_link(action)
    end
  end

  private

  def render_divider(action)
    label = action.label.is_a?(Hash) ? action.label[:label] : nil
    render Avo::DividerComponent.new(label)
  end

  def render_action_link(action)
    link_to action_path(action),
      data: action_data_attributes(action),
      title: action.action_name,
      class: action_css_class(action) do
        raw("#{icon(action)} #{action.action_name}")
      end
  end

  def action_data_attributes(action)
    {
      action_name: action.action_name,
      "turbo-frame": Avo::ACTIONS_TURBO_FRAME_ID,
      action: "click->actions-picker#visitAction",
      "actions-picker-target": action.standalone ? "standaloneAction" : "resourceAction",
      disabled: is_disabled?(action),
      turbo_prefetch: false,
    }
  end

  def action_css_class(action)
    "flex items-center px-4 py-3 w-full font-semibold text-sm hover:bg-primary-100 border-b#{is_disabled?(action) ? " text-gray-500" : " text-black"}"
  end
end
