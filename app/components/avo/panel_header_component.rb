# frozen_string_literal: true

class Avo::PanelHeaderComponent < Avo::BaseComponent
  include Avo::ApplicationHelper

  renders_one :name_slot
  renders_one :tools

  prop :name
  prop :description
  prop :display_breadcrumbs, default: false
  prop :profile_photo

  private

  def display_breadcrumbs?
    @display_breadcrumbs && Avo.configuration.display_breadcrumbs
  end

  def description
    return @description if @description.present?

    ""
  end

  def render?
    @name.present? || description.present? || tools.present? || display_breadcrumbs?
  end
end
