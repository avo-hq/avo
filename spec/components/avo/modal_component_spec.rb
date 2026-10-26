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

  # A dialog with no accessible name is announced as just "dialog"; the title and
  # description are on screen, so point the dialog at them. `aria-expanded` is a
  # disclosure attribute and means nothing on a dialog.
  it "names the dialog by its title and description" do
    render_inline(described_class.new(title: "Edit user", description: "Change the fields below")) { "Body" }

    dialog = page.find("[role=dialog]", visible: :all)
    expect(dialog["aria-expanded"]).to be_nil
    expect(page).to have_css("##{dialog["aria-labelledby"]}", text: "Edit user", visible: :all)
    expect(page).to have_css("##{dialog["aria-describedby"]}", text: "Change the fields below", visible: :all)
  end

  it "names the dialog by its heading slot" do
    render_inline(described_class.new) { |c| c.with_heading { "Release fish" } }

    dialog = page.find("[role=dialog]", visible: :all)
    expect(dialog["aria-labelledby"]).to be_present
    expect(page).to have_css("##{dialog["aria-labelledby"]}", text: "Release fish", visible: :all)
  end

  it "leaves off aria-labelledby and aria-describedby when there is nothing to point at" do
    render_inline(described_class.new) { "Body" }

    expect(page).to have_css("[role=dialog]:not([aria-labelledby]):not([aria-describedby])", visible: :all)
  end
end
