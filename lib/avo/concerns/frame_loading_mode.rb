# Adds the `loading:` mode option shared by tabs and association fields.
#
# `loading:` accepts either a symbol shorthand or a Hash:
#
#   loading: :manual                                   # placeholder + Load button, 15 min memory
#   loading: {mode: :manual}                           # same as above
#   loading: {mode: :manual, auto_load_for: 5.minutes} # custom sliding auto-load memory
#   loading: {mode: :manual, auto_load_for: 0}         # opt out — frame closes on next refresh
#   loading: {mode: :lazy}                             # native lazy (loads on reveal)
#
# This is orthogonal to the eager/lazy string returned by
# `Avo::Fields::Concerns::FrameLoading#turbo_frame_loading` — `manual?` is a
# separate predicate, not a `turbo_frame_loading` value.
#
# `auto_load_for` is a memory window, not a delay: once the user has opened the
# frame, a short-lived cookie (scoped per record + frame) remembers it, and the
# server renders a real auto-loading `<turbo-frame src>` — no placeholder, no
# Load button — on return for that duration. The window slides via the cookie's
# refreshed max-age. Manual frames default to a 15-minute window; pass an
# explicit `auto_load_for: 0` (or `nil`) to opt out. v1 honors `auto_load_for`
# for `:manual` only.
#
# When no per-call `loading:` is given, the host's `frame_loading_defaults`
# supply the fallback. Association fields read them from
# `Avo.configuration.associations = {frames: {loading:, auto_load_for:}}`
# (default `loading: :lazy`); tabs have no global default and stay eager.
module Avo
  module Concerns
    module FrameLoadingMode
      extend ActiveSupport::Concern

      # Global defaults this host falls back to when no per-call `loading:` is
      # given. Tabs have none (keeping the eager-inline default); association
      # fields override this to read `Avo.configuration.associations[:frames]`.
      def frame_loading_defaults
        {}
      end

      # How long a manual frame remembers an opened frame when neither the field
      # nor the global config pins an explicit `auto_load_for`.
      def default_manual_auto_load_for
        frame_loading_defaults.fetch(:auto_load_for, 15.minutes)
      end

      # The cold-start render mode: `:manual`, `:lazy`, or `nil` when unset.
      # A Hash without an explicit `mode:` defaults to `:manual`, so
      # `loading: {auto_load_for: 5.minutes}` is "manual + memory". With no
      # per-call `loading:` at all, fall back to the host's global default.
      def loading_mode
        return @loading_mode if defined?(@loading_mode)

        @loading_mode =
          if @loading.is_a?(Hash)
            (@loading.symbolize_keys[:mode] || :manual).to_sym
          elsif @loading.present?
            @loading.to_sym
          else
            frame_loading_defaults[:loading]
          end
      end

      # True when the frame should render as a manual placeholder (Load button)
      # on cold start. Covers `loading: :manual` and `loading: {mode: :manual}`.
      def manual?
        loading_mode == :manual
      end

      # True when `loading: {mode: :lazy}` — render a native lazy frame.
      def lazy_loading_mode?
        loading_mode == :lazy
      end

      # Seconds the browser should remember the opened frame and auto-load it on
      # return (sliding window). Accepts an `ActiveSupport::Duration` or a raw
      # integer. Returns `nil` (no memory window) when the frame isn't manual.
      #
      # Manual frames default to `default_manual_auto_load_for`. A developer can
      # override the window — or opt out entirely with `auto_load_for: 0`/`nil`,
      # which closes the frame again on the next refresh.
      def auto_load_for
        return @auto_load_for if defined?(@auto_load_for)

        options = @loading.is_a?(Hash) ? @loading.symbolize_keys : {}

        window =
          if options.key?(:auto_load_for)
            # An explicit per-field value wins, including `0`/`nil` (opt out).
            options[:auto_load_for]
          elsif manual?
            # Otherwise manual frames fall back to the configured default window.
            default_manual_auto_load_for
          end

        # `0`/`nil` (or a negative) means "no memory" — close again on refresh.
        seconds = window&.to_i
        @auto_load_for = (seconds if seconds&.positive?)
      end
    end
  end
end
