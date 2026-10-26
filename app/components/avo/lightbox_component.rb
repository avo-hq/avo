# frozen_string_literal: true

# Wraps a gallery so its images open in a native <dialog> lightbox.
#
# The block is the gallery markup. Every element inside it that carries the
# `lightbox` controller's `item` target and the image's action params (`src`,
# `title` and an optional `original` link) opens the dialog on that image; the
# dialog's prev/next buttons and the arrow keys then walk the items in DOM order.
# One dialog is rendered per gallery and lightbox_controller.js drives it.
#
# `enabled: false` renders the block alone, so a caller can pass a field's
# `lightbox` option straight through.
class Avo::LightboxComponent < Avo::BaseComponent
  prop :enabled, default: true
  prop :classes
end
