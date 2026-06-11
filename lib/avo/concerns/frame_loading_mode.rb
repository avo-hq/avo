# Adds the `loading:` mode option shared by tabs and association fields.
#
# `loading:` accepts either a symbol shorthand or a Hash:
#
#   loading: :manual                                  # placeholder + Load button
#   loading: {mode: :manual}                          # same as above
#   loading: {mode: :manual, auto_load_for: 5.minutes} # + sliding auto-load memory
#   loading: {mode: :lazy}                            # native lazy (loads on reveal)
#
# This is orthogonal to the eager/lazy string returned by
# `Avo::Fields::Concerns::FrameLoading#turbo_frame_loading` — `manual?` is a
# separate predicate, not a `turbo_frame_loading` value.
#
# `auto_load_for` is a memory window, not a delay: once the user has opened the
# frame, a short-lived cookie (scoped per record + frame) remembers it, and the
# server renders a real auto-loading `<turbo-frame src>` — no placeholder, no
# Load button — on return for that duration. The window slides via the cookie's
# refreshed max-age. v1 honors `auto_load_for` for `:manual` only.
module Avo
  module Concerns
    module FrameLoadingMode
      extend ActiveSupport::Concern

      # The cold-start render mode: `:manual`, `:lazy`, or `nil` when unset.
      # A Hash without an explicit `mode:` defaults to `:manual`, so
      # `loading: {auto_load_for: 5.minutes}` is "manual + memory".
      def loading_mode
        return @loading_mode if defined?(@loading_mode)

        @loading_mode =
          if @loading.is_a?(Hash)
            (@loading.symbolize_keys[:mode] || :manual).to_sym
          elsif @loading.present?
            @loading.to_sym
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
      # return (sliding window). `nil` unless a `loading: {auto_load_for: …}` Hash
      # was given. Accepts an `ActiveSupport::Duration` or a raw integer.
      def auto_load_for
        return unless @loading.is_a?(Hash)

        @loading.symbolize_keys[:auto_load_for]&.to_i
      end
    end
  end
end
