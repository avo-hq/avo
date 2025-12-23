# frozen_string_literal: true

class Avo::TabGroupComponent < Avo::BaseComponent
  delegate :group_param, to: :@group

  prop :resource, reader: :public
  # variable @group was changed with group to avoid cases where we need to pass down the group object as a prop
  prop :group, reader: :public
  prop :index, reader: :public
  prop :form, reader: :public
  prop :params, reader: :public
  prop :view, reader: :public

  def after_initialize
    group.index = index
  end

  def render?
    tabs_have_content? && visible_tabs.present?
  end

  def frame_args(tab)
    args = {
      target: :_top,
      class: "block"
    }

    if is_not_loaded?(tab)
      args[:loading] = :lazy
      args[:src] = helpers.resource_path(
        resource: resource,
        record: resource.record,
        keep_query_params: true,
        active_tab_title: tab.title,
        tab_turbo_frame: tab.turbo_frame_id(parent: group)
      )
    end

    args
  end

  def is_not_loaded?(tab)
    params[:tab_turbo_frame] != tab.turbo_frame_id(parent: group)
  end

  def tabs_have_content?
    visible_tabs.present?
  end

  def active_tab_title
    CGI.unescape(params[group_param] || group.visible_items&.first&.title)
  end

  def tabs
    group.visible_items.map do |tab|
      tab.hydrate(view: view)
    end
  end

  def visible_tabs
    tabs.select do |tab|
      tab.visible?
    end
  end

  def active_tab
    return if group.visible_items.blank?

    group.visible_items.find do |tab|
      tab.title.to_s == active_tab_title.to_s
    end
  end

  def args(tab)
    {
      # Hide the turbo frames that aren't in the current tab
      # This way we can lazy load the un-selected tabs on the show view
      class: "block space-y-4 #{"hidden" unless tab.title == active_tab_title}",
      data: {
        # Add a marker to know if we already loaded a turbo frame
        loaded: tab.title == active_tab_title,
        tabs_target: :tabPanel,
        tab_id: tab.title,
      }
    }
  end

  def scope_tab_path(scope_tab)
    base_options = {
      resource: resource,
      keep_query_params: true,
      active_tab_title: scope_tab.title,
      tab_turbo_frame: group.turbo_frame_id
    }

    if view.in?(%w[edit update])
      helpers.edit_resource_path(**base_options, record: resource.record)
    elsif view.in?(%w[new create])
      helpers.new_resource_path(**base_options)
    else
      helpers.resource_path(**base_options, record: resource.record)
    end
  end

  def scope_tab_data(scope_tab, current_tab)
    data = {
      action: "click->tabs#changeTab",
      tabs_tab_name_param: scope_tab.title,
      tabs_group_id_param: group.to_param,
      tabs_resource_name_param: resource.underscore_name,
      selected: scope_tab_active?(scope_tab, current_tab)
    }
    data[:tippy] = "tooltip" if scope_tab.description.present?
    data
  end
end
