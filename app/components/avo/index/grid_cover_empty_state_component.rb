# frozen_string_literal: true

class Avo::Index::GridCoverEmptyStateComponent < Avo::BaseComponent
  ICONS = %w[
    tabler/outline/star
    tabler/outline/bolt
    tabler/outline/clock
    tabler/outline/heart
    tabler/outline/leaf
    tabler/outline/sparkles
    tabler/outline/rocket
    tabler/outline/diamond
  ].freeze

  def icon_items
    ICONS.map.with_index do |path, index|
      {
        path:,
        v_edge: %w[top bottom].sample,
        v_px: rand(4..48),
        h_edge: %w[inset-inline-start inset-inline-end].sample,
        h_px: rand(4..56),
        rotation: rand(-15..15),
        duration: (3.2 + rand * 1.6).round(1),
        delay: (index * 0.35).round(2),
        intensity: rand(12..22)
      }
    end
  end
end
