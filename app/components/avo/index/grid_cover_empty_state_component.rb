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

  # Per-icon animation timing and color intensity (stable across all layouts)
  ICON_META = [
    {duration: 3.8, delay: 0.0,  intensity: 15},
    {duration: 4.2, delay: 0.4,  intensity: 18},
    {duration: 3.5, delay: 0.8,  intensity: 13},
    {duration: 4.6, delay: 1.2,  intensity: 20},
    {duration: 3.2, delay: 1.6,  intensity: 16},
    {duration: 4.8, delay: 2.0,  intensity: 14},
    {duration: 3.6, delay: 2.4,  intensity: 19},
    {duration: 4.4, delay: 2.8,  intensity: 17}
  ].freeze

  # 5 preset spatial layouts — each is an array of 8 position+rotation hashes.
  # v_edge: "top"|"bottom", h_edge: CSS logical "inset-inline-start"|"inset-inline-end"
  # v_px / h_px: distance in px from that edge. rotation: degrees.
  LAYOUTS = [
    # Layout 1 — scattered, original feel
    [
      {v_edge: "top",    v_px: 12, h_edge: "inset-inline-start", h_px: 16, rotation:  12},
      {v_edge: "top",    v_px: 16, h_edge: "inset-inline-end",   h_px: 20, rotation: -12},
      {v_edge: "top",    v_px: 72, h_edge: "inset-inline-start", h_px: 12, rotation:   0},
      {v_edge: "bottom", v_px: 12, h_edge: "inset-inline-start", h_px: 32, rotation:   6},
      {v_edge: "top",    v_px: 24, h_edge: "inset-inline-start", h_px: 72, rotation:  -6},
      {v_edge: "bottom", v_px: 16, h_edge: "inset-inline-end",   h_px: 20, rotation:  12},
      {v_edge: "top",    v_px: 12, h_edge: "inset-inline-end",   h_px: 40, rotation:  -6},
      {v_edge: "bottom", v_px: 12, h_edge: "inset-inline-end",   h_px: 48, rotation:   6}
    ],
    # Layout 2 — corners and mid-edges
    [
      {v_edge: "top",    v_px:  8, h_edge: "inset-inline-start", h_px:  8, rotation:  -8},
      {v_edge: "top",    v_px:  8, h_edge: "inset-inline-end",   h_px:  8, rotation:   8},
      {v_edge: "bottom", v_px:  8, h_edge: "inset-inline-start", h_px:  8, rotation:   8},
      {v_edge: "bottom", v_px:  8, h_edge: "inset-inline-end",   h_px:  8, rotation:  -8},
      {v_edge: "top",    v_px:  8, h_edge: "inset-inline-start", h_px: 56, rotation:   0},
      {v_edge: "bottom", v_px:  8, h_edge: "inset-inline-start", h_px: 56, rotation:   0},
      {v_edge: "top",    v_px: 48, h_edge: "inset-inline-start", h_px:  8, rotation:  12},
      {v_edge: "top",    v_px: 48, h_edge: "inset-inline-end",   h_px:  8, rotation: -12}
    ],
    # Layout 3 — diagonal scatter
    [
      {v_edge: "top",    v_px:  8, h_edge: "inset-inline-start", h_px: 24, rotation:  15},
      {v_edge: "top",    v_px: 32, h_edge: "inset-inline-end",   h_px: 12, rotation: -10},
      {v_edge: "top",    v_px: 56, h_edge: "inset-inline-start", h_px: 16, rotation:   5},
      {v_edge: "bottom", v_px: 56, h_edge: "inset-inline-end",   h_px: 16, rotation:  -5},
      {v_edge: "bottom", v_px: 32, h_edge: "inset-inline-start", h_px: 12, rotation:  10},
      {v_edge: "bottom", v_px:  8, h_edge: "inset-inline-end",   h_px: 24, rotation: -15},
      {v_edge: "top",    v_px: 20, h_edge: "inset-inline-start", h_px: 72, rotation:   8},
      {v_edge: "bottom", v_px: 20, h_edge: "inset-inline-end",   h_px: 48, rotation:  -8}
    ],
    # Layout 4 — even frame
    [
      {v_edge: "top",    v_px:  8, h_edge: "inset-inline-start", h_px: 32, rotation:  12},
      {v_edge: "top",    v_px:  8, h_edge: "inset-inline-end",   h_px: 32, rotation: -12},
      {v_edge: "top",    v_px: 48, h_edge: "inset-inline-start", h_px:  8, rotation:   0},
      {v_edge: "top",    v_px: 48, h_edge: "inset-inline-end",   h_px:  8, rotation:   0},
      {v_edge: "bottom", v_px: 48, h_edge: "inset-inline-start", h_px:  8, rotation:   6},
      {v_edge: "bottom", v_px: 48, h_edge: "inset-inline-end",   h_px:  8, rotation:  -6},
      {v_edge: "bottom", v_px:  8, h_edge: "inset-inline-start", h_px: 32, rotation: -12},
      {v_edge: "bottom", v_px:  8, h_edge: "inset-inline-end",   h_px: 32, rotation:  12}
    ],
    # Layout 5 — asymmetric cluster
    [
      {v_edge: "top",    v_px:  8, h_edge: "inset-inline-start", h_px:  8, rotation:   8},
      {v_edge: "top",    v_px: 24, h_edge: "inset-inline-start", h_px: 40, rotation:  -8},
      {v_edge: "top",    v_px:  8, h_edge: "inset-inline-end",   h_px: 24, rotation:  12},
      {v_edge: "top",    v_px: 56, h_edge: "inset-inline-end",   h_px:  8, rotation:  -5},
      {v_edge: "bottom", v_px:  8, h_edge: "inset-inline-start", h_px: 24, rotation: -12},
      {v_edge: "bottom", v_px: 40, h_edge: "inset-inline-start", h_px:  8, rotation:   8},
      {v_edge: "bottom", v_px:  8, h_edge: "inset-inline-end",   h_px:  8, rotation:  10},
      {v_edge: "bottom", v_px: 24, h_edge: "inset-inline-end",   h_px: 40, rotation: -10}
    ]
  ].freeze

  def icon_items
    layout = LAYOUTS.sample
    ICONS.each_with_index.map do |path, i|
      ICON_META[i].merge(layout[i]).merge(path: path)
    end
  end
end
