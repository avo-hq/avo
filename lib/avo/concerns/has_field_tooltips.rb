module Avo
  module Concerns
    # Hover tooltips on a field's label and value, declared with the field's
    # `tooltip:` and `label_tooltip:` options. tippy takes the text from
    # `title` and selects on `data-tippy`, so both attributes travel together.
    module HasFieldTooltips
      extend ActiveSupport::Concern

      def tooltip
        @resolved_tooltip ||= @field.tooltip
      end

      def label_tooltip
        @resolved_label_tooltip ||= @field.label_tooltip
      end

      def tooltip_attributes(text)
        return {} if text.blank?

        {title: text, data: {tippy: :tooltip}}
      end

      # Wraps the rendered value in the tooltip anchor. Inline hugs the value so
      # the bubble sits over a badge or a date rather than mid-row; block keeps
      # the width of values that fill the row (editors, maps, bars). Rendered
      # only when there is a tooltip: an empty wrapper would still change how
      # the value sizes.
      def value_tooltip_anchor(block: false, &content_block)
        return capture(&content_block) if tooltip.blank?

        content_tag :div,
          class: class_names("tooltip-anchor", block ? "tooltip-anchor--block" : "tooltip-anchor--inline"),
          **tooltip_attributes(tooltip),
          &content_block
      end
    end
  end
end
