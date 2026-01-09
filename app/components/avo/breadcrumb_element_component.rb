# frozen_string_literal: true

class Avo::BreadcrumbElementComponent < Avo::BaseComponent
  prop :text
  prop :url, default: nil
  prop :icon, default: nil
  prop :separator, default: nil
  prop :initials, default: nil
  prop :avatar

  def link?
    @url.present?
  end

  def wrapper_element(args = {}, &block)
    if link?
      link_to @url, **args, &block
    else
      content_tag :span, **args, &block
    end
  end
end
