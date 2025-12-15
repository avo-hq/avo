# frozen_string_literal: true

module Avo
  module UI
    class TabsComponent < Avo::BaseComponent
      VARIANTS = %i[group scope].freeze

      renders_many :items, Avo::UI::TabComponent

      prop :variant, default: :group # :group (no border) or :scope (with border)
      prop :aria_label
      prop :id

      # Ensure TabItems inherit parent variant unless explicitly overridden
      alias_method :with_item_without_variant, :with_item
      def with_item(**attrs, &block)
        attrs[:variant] ||= @variant
        with_item_without_variant(**attrs, &block)
      end

      def classes
        base = "tabs"
        variant_class = (@variant == :scope) ? "tabs--scope" : "tabs--group"
        "#{base} #{variant_class}"
      end

      def tablist_id
        @id || "tabs-#{object_id}"
      end

      def tablist_aria_label
        @aria_label || "Tabs navigation"
      end
    end
  end
end
