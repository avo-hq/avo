# frozen_string_literal: true

class Avo::DiscreetInformationComponent < Avo::BaseComponent
  prop :payload

  def items
    @payload.items.compact
  end

  def element_tag(item)
    if item.url.present?
      :a
    else
      :div
    end
  end

  def element_attributes(item)
    if item.url.present?
      {href: item.url, target: item.url_target}
    else
      {}
    end
  end
end
