# frozen_string_literal: true

class Avo::PanelComponent < Avo::BaseComponent
  include Avo::ApplicationHelper

  delegate :white_panel_classes, to: :helpers

  renders_one :cover_slot
  renders_one :name_slot
  renders_one :tools
  renders_one :body
  renders_one :sidebar
  renders_one :bare_sidebar
  renders_one :bare_content
  renders_one :footer_tools
  renders_one :footer

  prop :description
  prop :body_classes
  prop :data, default: {}.freeze
  prop :display_breadcrumbs, default: false
  prop :index
  prop :classes
  prop :profile_photo
  prop :cover_photo
  prop :args, nil, :**, default: {}.freeze
  prop :name do |value|
    value || @args&.dig(:title)
  end

  def classes
    class_names(@classes, "has-cover-photo": @cover_photo.present?, "has-profile-photo": @profile_photo.present?)
  end

  private

  def data_attributes
    @data.merge({"panel-index": @index})
  end

  def display_breadcrumbs?
    @display_breadcrumbs == true && Avo.configuration.display_breadcrumbs == true
  end

  def description
    return @description if @description.present?

    ""
  end

  def render_header?
    @name.present? || description.present? || tools.present? || display_breadcrumbs?
  end
end
