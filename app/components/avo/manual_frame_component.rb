# frozen_string_literal: true

# Renders a `<turbo-frame>` with NO `src` that defers loading until the user
# clicks the "Load" button. Used by manual (`loading: :manual`) tabs and
# associations on Show pages.
#
# The frame carries the deferred URL in `data-manual-frame-url-value` for the
# `manual-frame` Stimulus controller, which sets the frame `src` on click and
# renders an inline error + Retry on failure. It is marked `data-manual-frame`
# as an identifying hook.
#
# States (single component, three states):
# - placeholder: title + a "Load <title>" button
# - loading: `Avo::LoadingComponent` spinner while the request is in flight
# - error: inline message + Retry
class Avo::ManualFrameComponent < Avo::BaseComponent
  # @param frame_id [String] the `<turbo-frame>` id (positional)
  # @param deferred_url [String] the URL the controller loads on click
  # @param title [String] label source; callers pass an already display-ready
  #   name (a field's `plural_name`/`name` or a tab title), used verbatim
  # @param classes [String, nil] extra CSS classes for the `.state` placeholder container
  prop :frame_id, kind: :positional
  prop :deferred_url
  prop :title
  prop :classes

  # The display label. Callers already hand us presentation-ready, translated
  # text (field name / tab title), so we use it as-is — never `humanize`, which
  # would mangle custom or translated names ("Order Items" -> "Order items").
  def label
    @title.to_s
  end

  # "Load <title>" — interpolated so the full phrase is translatable, matching
  # the codebase's `attach_item`/`create_new_item` convention.
  def load_label
    t("avo.load_item", item: label)
  end

  # The Retry button's aria-label: "Retry <title>" (the visible copy is just
  # "Retry"; the aria-label scopes it to this frame for screen readers).
  def retry_label
    t("avo.retry_item", item: label)
  end
end
