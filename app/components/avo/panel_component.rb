# frozen_string_literal: true

class Avo::PanelComponent < ViewComponent::Base
  include Avo::ApplicationHelper

  attr_reader :title # deprecating title in favor of name
  attr_reader :name

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

  def initialize(name: nil, description: nil, body_classes: nil, data: {}, display_breadcrumbs: false, index: nil, classes: nil, profile_photo: nil, cover_photo: nil, **args)
    # deprecating title in favor of name
    @title = args[:title]
    @name = name || title
    @description = description
    @classes = classes
    @body_classes = body_classes
    @data = data
    @display_breadcrumbs = display_breadcrumbs
    @index = index
    @profile_photo = profile_photo
    @cover_photo = cover_photo
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
