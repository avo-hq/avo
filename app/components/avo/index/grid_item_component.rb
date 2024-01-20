# frozen_string_literal: true

class Avo::Index::GridItemComponent < Avo::BaseComponent
  include Avo::ResourcesHelper
  include Avo::Fields::Concerns::HasHTMLAttributes

  attr_reader :parent_resource, :actions

  def initialize(resource: nil, reflection: nil, parent_record: nil, parent_resource: nil, actions: nil)
    @resource = resource
    @reflection = reflection
    @parent_record = parent_record
    @parent_resource = parent_resource
    @actions = actions
    @card = Avo::ExecutionContext.new(target: resource.grid_view[:card], resource: resource, record: resource.record).handle
    @whole_html = Avo::ExecutionContext.new(target: resource.grid_view[:html], resource: resource, record: resource.record).handle
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
        via_resource_class: parent_resource.class.to_s,
        via_record_id: @parent_record.to_param
      }
    end

    helpers.resource_view_path(record: @resource.record, resource: parent_or_child_resource, **args)
  end

  def render_cover
    classes = "object-cover"
    unless @card[:cover_url].present?
      classes = "bg-gray-50"
      image_classes = "relative transform -translate-x-1/2 -translate-y-1/2 h-20 inset-auto top-1/2 left-1/2" 
    end

    link_to resource_view_path, title: @card[:title] do
      content_tag :div, class: "absolute h-full w-full #{classes}" do
        image_tag @card[:cover_url] || Avo.configuration.branding.placeholder, class: image_classes
      end
    end
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
end
