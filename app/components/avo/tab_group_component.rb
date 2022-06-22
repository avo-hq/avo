# frozen_string_literal: true

class Avo::TabGroupComponent < Avo::BaseComponent
  attr_reader :group
  attr_reader :index
  attr_reader :view
  attr_reader :form

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
    active_tab.present?
  end

  def active_tab_name
    params[:active_tab_name] || group.items.first.name
  end

  def active_tab
    group&.items.find do |tab|
      tab.name.to_s == active_tab_name.to_s
    end

    # active_tab = if params[:tab_turbo_frame].present? && params[:active_tab_name].present?
    #   item&.items.find do |tab|
    #     tab.name.to_s == params[:active_tab_name].to_s
    #   end
    # else
    #   item.items.find do |tab|
    #     tab.name.to_s == active_tab_name
    #   end
    # end
  end
end
