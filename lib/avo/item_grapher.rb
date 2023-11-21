# Use it like this:
# Avo::ItemGrapher.new(resource).render(view: :edit)
class Avo::ItemGrapher
  attr_reader :item

  def initialize(item)
    @item = item
  end

  def decode_item(item)
    result = ""
    result << "──" * (item[:level])
    result << "→"
    result << item[:id]
    if item[:items].present?
      item[:items].each do |itm|
        result << "<br />"
        result << decode_item(itm)
      end

    end
    result
  end

  def unwrap(i, level = 0, view: :show)
    result = []

    i.items.each do |item|
      label = ""
      label << item.class.name.demodulize
      label << " "
      if item.respond_to?(:name)
        label << "{#{item.name}}"
        label << " "
      end
      label << (item.hydrate(view: view).visible_in_view?(view: view) ? "visible" : "invisible")
      if item.class.ancestors.include?(Avo::Concerns::HasItems)
        if item.visible_items.present?
          label << " | HAS_ITEMS #{item.visible_items.count} items"
          # abort item.visible_items.inspect
          label << item.visible_items.map(&:class).inspect
        else
          label << " | DOES_NOT_HAVE_ITEMS"
        end
      end
      if item.respond_to?(:is_empty?)
        label << " "
        label << (item.is_empty? ? "[IS EMPTY!]" : "[#{item.visible_items.count}]")
      end
      payload = if item.respond_to?(:items) && item.items.present?
        {
          id: label,
          items: unwrap(item, level + 1),
        }
      else
        {
          id: label
        }
      end

      result << {
        **payload,
        level: level,
      }
    end

    result
  end

  def render(**args)
    result = unwrap(item, **args)
      .map do |item|
        decode_item(item)
      end
      .join("<br />")
    "<pre>#{result}</pre>".html_safe
  end
end
