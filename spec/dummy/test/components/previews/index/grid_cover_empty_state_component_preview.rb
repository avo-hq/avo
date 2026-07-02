# frozen_string_literal: true

module Index
  class GridCoverEmptyStateComponentPreview < ViewComponent::Preview
    # Default — matches the real grid card image container (160px tall)
    def default
      render_with_template
    end

    # Wide — full-width container to confirm icon scatter holds up
    def wide
      render_with_template
    end
  end
end
