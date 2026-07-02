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
  # @param description [String, nil] the field/tab description, shown beside the
  #   title when present (already resolved by the caller)
  # @param auto_load_for [Integer, nil] seconds the browser should remember an
  #   opened frame and auto-load it on return (sliding window). `nil` disables
  #   the memory — the frame stays a click-to-load placeholder every visit.
  # @param cookie_name [String, nil] the cookie the Stimulus controller writes on
  #   a successful load so the server can render this frame without the Load
  #   button on the next visit. Paired with `auto_load_for`; both come from the
  #   `manual_frame_*` application helpers. `nil` when there's no memory window.
  # @param classes [String, nil] extra CSS classes for the placeholder container
  prop :frame_id, kind: :positional
  prop :deferred_url
  prop :title
  prop :description
  prop :auto_load_for
  prop :cookie_name
  prop :classes

  # The display label. Callers already hand us presentation-ready, translated
  # text (field name / tab title), so we use it as-is. Never `humanize`, which
  # would mangle custom or translated names ("Order Items" -> "Order items").
  def label
    @title.to_s
  end

  # "Load <title>", interpolated so the full phrase is translatable, matching
  # the codebase's `attach_item`/`create_new_item` convention.
  def load_label
    t("avo.load_item", item: label)
  end

  # The Retry button's aria-label: "Retry <title>" (the visible copy is just
  # "Retry"; the aria-label scopes it to this frame for screen readers).
  def retry_label
    t("avo.retry_item", item: label)
  end

  # In development only, a link straight to the deferred URL so a developer can
  # open the failing frame on its own and read the real error / stack trace
  # (the inline error state otherwise swallows the response). Mirrors the
  # dev-only link in `avo/home/failed_to_load.html.erb`. Returns nil elsewhere.
  def dev_details_note
    return unless Rails.env.development? && @deferred_url.present?

    helpers.tag.p(class: "manual-frame__error-note") do
      helpers.safe_join([
        "Follow ",
        helpers.link_to("this link", @deferred_url, target: "_blank", rel: "noopener", class: "manual-frame__error-link"),
        " for more details about the issue and how to fix it."
      ])
    end
  end
end
