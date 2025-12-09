# frozen_string_literal: true

class Avo::PanelComponent < Avo::BaseComponent
  include Avo::ApplicationHelper

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
  prop :discreet_information
  prop :index
  prop :classes
  # prop :profile_photo
  # prop :cover_photo
  prop :args, kind: :**, default: {}.freeze
  prop :external_link

  def after_initialize
    @name = @args.dig(:name) || @args.dig(:title)
  end

  def classes
    class_names(@classes, "has-cover-photo": @cover_photo.present?, "has-profile-photo": @profile_photo.present?)
  end

  private

  def data_attributes
    @data.merge(component: @data[:component] || self.class.to_s.underscore, "panel-index": @index)
  end
end
