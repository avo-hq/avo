require "rails_helper"

RSpec.describe Avo::ModalComponent, type: :component do
  # A modal left open when the page is cached would come back open on a restoration visit.
  it "keeps an ephemeral modal out of the Turbo cache" do
    render_inline(described_class.new) { "Body" }

    expect(page).to have_css(".modal[data-controller~='modal'][data-turbo-temporary]", visible: :all)
  end

  # A persistent modal lives in the page closed, so the cached page needs it.
  it "caches a persistent modal with the page" do
    render_inline(described_class.new(behavior: :persistent)) { "Body" }

    expect(page).to have_css(".modal[data-controller~='persistent-modal']", visible: :all)
    expect(page).not_to have_css(".modal[data-turbo-temporary]", visible: :all)
  end
end
