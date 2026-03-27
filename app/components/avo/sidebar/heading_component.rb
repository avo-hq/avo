# frozen_string_literal: true

class Avo::Sidebar::HeadingComponent < Avo::BaseComponent
  prop :title
  prop :icon
  prop :collapsable, default: false
  prop :collapsed, default: false
  prop :key

  def render? = @title.present?
end
