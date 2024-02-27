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
end
