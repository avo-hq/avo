module Avo
  module Fields
    module Concerns
      module FrameLoading
        extend ActiveSupport::Concern

        def turbo_frame_loading
          kwargs[:turbo_frame_loading] || params[:turbo_frame_loading] || "eager"
        end
      end
    end
  end
end
