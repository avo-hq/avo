# frozen_string_literal: true

class Avo::ActionsComponent < ViewComponent::Base
  include Avo::ApplicationHelper
  attr_reader :label, :size, :as_row_control

  def initialize(actions: [], resource: nil, view: nil, exclude: [], include: [], style: :outline, color: :primary, label: nil, size: :md, as_row_control: false)
    @actions = actions || []
    @resource = resource
    @view = view
    @exclude = Array(exclude)
    @include = include
    @color = color
    @style = style
    @label = label || I18n.t("avo.actions")
    @size = size
    @as_row_control = as_row_control
  end

  def render?
    actions.present?
  end

  def actions
    if @exclude.present?
      @actions.reject { |action| action.class.in?(@exclude) }
    elsif @include.present?
      @actions.select { |action| action.class.in?(@include) }
    else
      @actions
    end
  end

  # When running an action for one record we should do it on a special path.
  # We do that so we get the `record` param inside the action so we can prefill fields.
  def action_path(action)
    return single_record_path(action) if as_row_control
    return many_records_path(action) unless @resource.has_record_id?

    if on_record_page?
      single_record_path action
    else
      many_records_path action
    end
  end

  # How should the action be displayed by default
  def is_disabled?(action)
    return false if action.standalone || as_row_control

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
end
