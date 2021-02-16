# frozen_string_literal: true

class Avo::ResourceShowComponent < ViewComponent::Base
  include Avo::ResourcesHelper
  include Avo::ApplicationHelper

  attr_reader :fields_by_panel, :has_one_panels, :has_many_panels, :has_as_belongs_to_many_panels

  def initialize(resource: nil)
    @resource = resource

    split_panel_fields
  end

  def back_path
    if creates_via_resource
      helpers.resource_path(params[:via_resource_name].safe_constantize, resource_id: params[:via_resource_id])
    else
      helpers.resources_path(@resource.model)
    end
  end

  def edit_path
    helpers.edit_resource_path(@resource.model)
  end

  private
    def creates_via_resource
      params[:via_resource_name].present? and params[:via_resource_id].present?
    end

    def split_panel_fields
      @fields_by_panel = {}
      @has_one_panels = []
      @has_many_panels = []
      @has_as_belongs_to_many_panels = []

      @resource.get_fields.each do |field|
        case field.class.to_s
        when 'Avo::Fields::HasOneField'
          @has_one_panels << field
        when 'Avo::Fields::HasManyField'
          @has_many_panels << field
        when 'Avo::Fields::HasAndBelongsToManyField'
          @has_as_belongs_to_many_panels << field
        else
          @fields_by_panel[field.panel_name] ||= []
          @fields_by_panel[field.panel_name] << field
        end
      end

    end
end
