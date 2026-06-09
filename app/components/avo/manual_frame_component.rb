# frozen_string_literal: true

# Renders a `<turbo-frame>` with NO `src` that defers loading until the user
# clicks the "Load" button. Used by manual (`loading: :manual`) tabs and
# associations on Show pages.
#
# The frame is marked `data-manual-frame` so the global HTTP-500 handler in
# `application.js` skips it, and it carries the deferred URL in
# `data-manual-frame-url-value` for the `manual-frame` Stimulus controller,
# which sets the frame `src` on click.
#
# States (single component, three states):
# - placeholder: title + a "Load <title>" button (this unit)
# - loading: `Avo::LoadingComponent` spinner while the request is in flight
# - error: inline message + Retry (slotted in by Unit 5)
class Avo::ManualFrameComponent < Avo::BaseComponent
  # @param frame_id [String] the `<turbo-frame>` id (positional)
  # @param deferred_url [String] the URL the controller loads on click
  # @param title [String] label source; the button reads "Load <title humanized>"
  # @param classes [String, nil] extra CSS classes for the `.state` placeholder container
  prop :frame_id, kind: :positional
  prop :deferred_url
  prop :title
  prop :classes

  # Humanized label derived from the title (e.g. "order_items" -> "Order items").
  def label
    @title.to_s.humanize
  end

  # The button copy and aria-label: "Load <title>".
  def load_label
    t("avo.load") + " " + label
  end
end
