class LightboxComponentPreview < ViewComponent::Preview
  # Lightbox Component
  # ------------------
  # Wraps a gallery so its images open in a native <dialog> lightbox.
  # Click a thumbnail to open it; the arrow buttons and arrow keys cycle
  # through the gallery, Escape or a click on the backdrop closes it, and the
  # toolbar links to the original file.
  def default
    render_with_template(
      template: "lightbox_component_preview/default",
      locals: {images: sample_images}
    )
  end

  # A single image hides the prev/next buttons and the counter.
  def single_image
    render_with_template(
      template: "lightbox_component_preview/default",
      locals: {images: sample_images.first(1)}
    )
  end

  # `enabled: false` renders the gallery alone: plain images, no dialog.
  def disabled
    render_with_template(
      template: "lightbox_component_preview/default",
      locals: {images: sample_images, enabled: false}
    )
  end

  private

  def sample_images
    [
      ["sunrise.jpg", "#f59e0b", "#fde68a"],
      ["ocean.jpg", "#0ea5e9", "#bae6fd"],
      ["forest.jpg", "#16a34a", "#bbf7d0"],
      ["dusk.jpg", "#7c3aed", "#ddd6fe"]
    ].map do |title, from, to|
      {title: title, src: placeholder_image(title, from, to)}
    end
  end

  def placeholder_image(title, from, to)
    svg = <<~SVG
      <svg xmlns="http://www.w3.org/2000/svg" width="1200" height="675" viewBox="0 0 1200 675">
        <defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#{from}"/><stop offset="1" stop-color="#{to}"/></linearGradient></defs>
        <rect width="1200" height="675" fill="url(#g)"/>
        <text x="600" y="360" font-family="sans-serif" font-size="64" fill="white" text-anchor="middle">#{title}</text>
      </svg>
    SVG

    "data:image/svg+xml;utf8,#{ERB::Util.url_encode(svg)}"
  end
end
