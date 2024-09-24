# frozen_string_literal: true

class Avo::ActionsComponent < Avo::BaseComponent
  include Avo::ApplicationHelper

  ACTION_FILTER = _Set(_Class(Avo::BaseAction))

  prop :as_row_control, _Boolean, default: false
  prop :icon, _Nilable(String)
  prop :size, Avo::ButtonComponent::SIZE, default: :md
  prop :title, _Nilable(String)
  prop :color, Symbol, default: :primary
  prop :include, _Nilable(ACTION_FILTER), default: [].freeze do |include|
    Array(include).to_set
  end
  prop :label, String do |label|
    label || I18n.t("avo.actions")
  end
  prop :style, Avo::ButtonComponent::STYLE, default: :outline
  prop :actions, _Array(Avo::BaseAction), default: [].freeze
  prop :exclude, _Nilable(ACTION_FILTER), default: [].freeze do |exclude|
    Array(exclude).to_set
  end
  prop :resource, _Nilable(Avo::BaseResource)
  prop :view, _Nilable(Avo::ViewInquirer)

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
    link_to action.link_arguments(resource: @resource, arguments: action.arguments).first,
      data: action_data_attributes(action),
      title: action.action_name,
      class: action_css_class(action) do
        raw("#{icon(action)} #{action.action_name}")
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
