# frozen_string_literal: true

class Avo::PanelComponent < Avo::BaseComponent
  include Avo::ApplicationHelper

  attr_reader :title # deprecating title in favor of name

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

  prop :name, _Nilable(String), reader: :public
  prop :description, _Nilable(String)
  prop :body_classes, _Nilable(String)
  prop :data, Hash, default: {}.freeze
  prop :display_breadcrumbs, _Boolean, default: false
  prop :index, _Nilable(Integer)
  prop :classes, _Nilable(String)
  prop :profile_photo, _Nilable(Avo::ProfilePhoto)
  prop :cover_photo, _Nilable(Avo::CoverPhoto)
  prop :args, Hash, :**, default: {}.freeze

  def after_initialize
    @title = @args[:title]
    @name = name || title
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
