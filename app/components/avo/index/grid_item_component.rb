# frozen_string_literal: true

class Avo::Index::GridItemComponent < Avo::BaseComponent
  include Avo::ResourcesHelper
  include Avo::Fields::Concerns::HasHTMLAttributes

  prop :resource
  prop :reflection
  prop :parent_record
  prop :parent_resource
  prop :actions

  def after_initialize
    @card = Avo::ExecutionContext.new(target: @resource.grid_view[:card], resource: @resource, record: @resource.record).handle
    @whole_html = Avo::ExecutionContext.new(target: @resource.grid_view[:html], resource: @resource, record: @resource.record).handle
  end

  private

  def html(element, type)
    return "" if @whole_html.nil? || (@html = @whole_html[element]).nil?

    get_html(type, view: :index, element: :wrapper)
  end

  def resource_view_path
    args = {}

    if @parent_record.present?
      args = {
        via_resource_class: @parent_resource.class.to_s,
        via_record_id: @parent_record.to_param
      }
    end

    helpers.resource_view_path(record: @resource.record, resource: parent_or_child_resource, **args)
  end

  def render_cover
    return link_to_cover if @card[:cover_url].present?

    link_to resource_view_path do
      render Avo::Index::GridCoverEmptyStateComponent.new
    end
  end

  def link_to_cover
    classes = "absolute h-full w-full object-cover"

    link_to image_tag(@card[:cover_url], class: classes), resource_view_path, class: classes, title: @card[:title], loading: :lazy, width: "640", height: "480"
  end

  def render_title
    return if @card[:title].blank?

    content_tag :div, class: "grid font-semibold leading-tight text-lg mb-2 #{html(:title, :classes)}", style: html(:title, :style) do
      link_to @card[:title], resource_view_path
    end
  end

  def render_body
    return if @card[:body].blank?

    content_tag :div, class: "text-sm break-words text-gray-500 #{html(:body, :classes)}", style: html(:body, :style) do
      @card[:body]
    end
  end

  def render_badge
    return if @card[:badge_label].blank?

    content_tag :div, class: class_names("absolute block inset-auto top-0 right-0 mt-2 mr-2 text-sm font-semibold bg-#{badge_color}-50 border border-#{badge_color}-300 text-#{badge_color}-700 rounded shadow-lg px-2 py-px z-10", html(:badge, :classes)), style: html(:badge, :style), data: { target: :badge, **(html(:badge, :data).presence || {}) } do
      @card[:badge_label]
    end
  end

  def badge_color
    @card[:badge_color] || "gray"
  end
end
