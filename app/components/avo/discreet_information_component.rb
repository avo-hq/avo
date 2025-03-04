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

  def element_classes(item)
    if item.as_badge
      %w(whitespace-nowrap rounded-md uppercase px-2 py-1 text-xs font-bold block text-center truncate bg-gray-500 text-white)
    else
      %w(flex gap-1 text-xs font-normal text-gray-600 hover:text-gray-900)
    end
  end

  def data(item) = item.data || {}
end
