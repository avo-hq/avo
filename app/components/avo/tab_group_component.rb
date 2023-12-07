# frozen_string_literal: true

class Avo::TabGroupComponent < Avo::BaseComponent
  attr_reader :group
  attr_reader :index
  attr_reader :view
  attr_reader :form
  attr_reader :resource

  def initialize(resource:, group:, index:, form:, params:, view:)
    @resource = resource
    @group = group
    @index = index
    @form = form
    @params = params
    @view = view

    @group.index = index
  end

  def render?
    tabs_have_content? && visible_tabs.present?
  end

  def tabs_have_content?
    visible_tabs.present?
  end

  def group_param
    group.id
  end

  def active_tab_name
    CGI.unescape(params[group_param] || group.visible_items&.first&.name)
  end

  def tabs
    @group.visible_items.map do |tab|
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
      tab.name.to_s == active_tab_name.to_s
    end
  end
end
