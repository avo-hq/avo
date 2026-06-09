# Adds the `loading:` mode option shared by tabs and association fields.
#
# v1 only carries `:manual`. This is orthogonal to the eager/lazy string
# returned by `Avo::Fields::Concerns::FrameLoading#turbo_frame_loading` —
# `manual?` is a separate predicate, not a `turbo_frame_loading` value.
module Avo
  module Concerns
    module FrameLoadingMode
      extend ActiveSupport::Concern

      # Returns true only when `loading: :manual` was set (string "manual" tolerated).
      def manual?
        @loading.to_s == "manual"
      end
    end
  end
end
