require "rails_helper"

RSpec.describe Avo::LightboxComponent, type: :component do
  let(:gallery) { '<img src="/first.jpg" class="thumb">'.html_safe }

  it "wraps the gallery in the lightbox controller with one dialog" do
    render_inline(described_class.new) { gallery }

    # avo-ai registers a `lightbox` controller on the same Stimulus application; core's is `image-lightbox`.
    expect(page.find("[data-controller]")["data-controller"]).to eq "image-lightbox"
    expect(page).to have_css("[data-controller='image-lightbox'] img.thumb[src='/first.jpg']")
    expect(page).to have_css("dialog.lightbox[data-image-lightbox-target='dialog']", count: 1, visible: :all)
    expect(page).to have_css("dialog.lightbox img.lightbox__image[data-image-lightbox-target='image']", visible: :all)
    expect(page).to have_css("dialog.lightbox .lightbox__caption[data-image-lightbox-target='caption']", visible: :all)
  end

  it "renders the navigation, close and open-original controls" do
    render_inline(described_class.new) { gallery }

    expect(page).to have_css("button.lightbox__nav--prev[data-action='click->image-lightbox#prev'][aria-label='Previous image']", visible: :all)
    expect(page).to have_css("button.lightbox__nav--next[data-action='click->image-lightbox#next'][aria-label='Next image']", visible: :all)
    expect(page).to have_css("button.lightbox__action[data-action='click->image-lightbox#close'][aria-label='Close']", visible: :all)
    expect(page).to have_css("a.lightbox__action[target='_blank'][rel='noopener noreferrer'][data-image-lightbox-target='original']", visible: :all)
  end

  it "closes on a backdrop click and tears down on the dialog's close event" do
    render_inline(described_class.new) { gallery }

    expect(page.find("dialog.lightbox", visible: :all)["data-action"]).to include("pointerdown->image-lightbox#trackPointerDown", "click->image-lightbox#closeOnBackdrop", "close->image-lightbox#closed")
  end

  it "renders only the gallery when disabled" do
    render_inline(described_class.new(enabled: false)) { gallery }

    expect(page).to have_css("img.thumb[src='/first.jpg']")
    expect(page).not_to have_css("[data-controller='image-lightbox']")
    expect(page).not_to have_css("dialog", visible: :all)
  end
end
