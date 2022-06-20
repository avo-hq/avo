# frozen_string_literal: true

class Avo::ActionsComponent < ViewComponent::Base
  include Avo::ApplicationHelper

  def initialize(actions: [], resource: nil, view: nil)
    @actions = actions
    @resource = resource
    @view = view
  end

  def render?
    @actions.present?
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
    "#{@resource.record_path}/actions/#{id}"
  end

  def many_records_path(id)
    "#{@resource.records_path}/actions/#{id}"
  end
end
