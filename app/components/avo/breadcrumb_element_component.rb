# frozen_string_literal: true

class Avo::BreadcrumbElementComponent < Avo::BaseComponent
  prop :text
  prop :url, default: nil
  prop :icon, default: nil
  prop :separator, default: nil
  prop :current, default: false

  def current?
    @current
  end

  def link?
    @url.present? && !current?
  end
end

