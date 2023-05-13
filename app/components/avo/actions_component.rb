# frozen_string_literal: true

class Avo::ActionsComponent < ViewComponent::Base
  include Avo::ApplicationHelper
  attr_reader :label

  def initialize(actions: [], resource: nil, view: nil, exclude: [], include: [], style: :outline, color: :primary, label: nil)
    @actions = actions || []
    @resource = resource
    @view = view
    @exclude = exclude
    @include = include
    @color = color
    @style = style
    @label = label || I18n.t("avo.actions")
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
  # We do that so we get the `model` param inside the action so we can prefill fields.
  def action_path(id)
    return many_records_path(id) unless @resource.has_model_id?

    if on_record_page?
      single_record_path id
    else
      many_records_path id
    end
  end

  # How should the action be displayed by default
  def is_disabled?(action)
    return false if action.standalone

    on_index_page?
  end

  private

  def on_record_page?
    @view.in?([:show, :edit, :new])
  end

  def on_index_page?
    !on_record_page?
  end

  def single_record_path(id)
    Avo::Services::URIService.parse(@resource.record_path)
      .append_paths("actions")
      .append_query("action_id": id)
      .to_s
  end

  def many_records_path(id)
    Avo::Services::URIService.parse(@resource.records_path)
      .append_paths("actions")
      .append_query("action_id": id)
      .to_s
  end
end
