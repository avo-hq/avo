require "rails_helper"

RSpec.describe FrameLoadFailedComponentPreview, type: :component do
  it "renders the default preview" do
    render_preview(:default, from: described_class, params: {
      frame: "filter",
      src: "/admin/resources/comments"
    })

    expect(page).to have_css(".state--frame-load-failed")
    expect(page).to have_text("Failed to load:")
    expect(page).to have_text("filter")
    # Dev note with link is only shown when Rails.env.development? — test env skips it
  end
end
