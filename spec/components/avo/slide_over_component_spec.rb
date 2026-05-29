require "rails_helper"

RSpec.describe Avo::SlideOverComponent, type: :component do
  it "renders the slide-over shell wired to the slide-over Stimulus controller" do
    render_inline(described_class.new) { "body" }

    expect(page).to have_css(".slide-over[data-controller='slide-over']")
    expect(page).to have_css(".slide-over__panel[role='dialog'][aria-modal='true']")
    expect(page).to have_css(".slide-over__body", text: "body")
  end

  it "wraps in the Avo::SLIDE_OVER_FRAME_ID turbo frame so close helpers can target it" do
    render_inline(described_class.new) { "body" }

    expect(page).to have_css("turbo-frame##{Avo::SLIDE_OVER_FRAME_ID}")
  end

  it "renders the heading slot inside the header" do
    render_inline(described_class.new) do |c|
      c.with_heading { "Bulk update - 4 records" }
      "body"
    end

    expect(page).to have_css(".slide-over__header .slide-over__heading", text: "Bulk update - 4 records")
  end

  it "renders the controls slot inside the footer" do
    render_inline(described_class.new) do |c|
      c.with_controls { "<button type=\"button\">Submit</button>".html_safe }
      "body"
    end

    expect(page).to have_css(".slide-over__footer button", text: "Submit")
  end

  it "hides the footer when no controls slot is provided" do
    render_inline(described_class.new) { "body" }

    expect(page).not_to have_css(".slide-over__footer")
  end

  it "applies the width modifier class" do
    render_inline(described_class.new(width: :lg)) { "body" }

    expect(page).to have_css(".slide-over--width-lg")
  end

  it "wires the backdrop click action and value to the slide-over controller" do
    render_inline(described_class.new(close_on_backdrop_click: false)) { "body" }

    backdrop = page.find(".slide-over__backdrop")
    expect(backdrop["data-action"]).to eq "click->slide-over#close"
    expect(page).to have_css(".slide-over[data-slide-over-close-modal-on-backdrop-click-value='false']")
  end

  it "renders the bottom-sheet modifier when applied via the class prop" do
    render_inline(described_class.new(class: "slide-over--bottom-sheet")) { "body" }

    expect(page).to have_css(".slide-over.slide-over--bottom-sheet")
  end

  it "uses the slide-over controller (not the modal controller) for body-class isolation" do
    render_inline(described_class.new) { "body" }

    # Body-class isolation: this component must drive the slide-over controller,
    # which toggles `body.slide-over-open` — NOT the modal controller, which
    # would toggle `body.modal-open`.
    expect(page).to have_css(".slide-over[data-controller='slide-over']")
    expect(page).not_to have_css("[data-controller~='modal']")
    expect(page).not_to have_css("[data-controller~='persistent-modal']")
  end

  it "renders the close button by default" do
    render_inline(described_class.new) { "body" }

    expect(page).to have_css("button.slide-over__close[data-action='click->slide-over#closeModal']")
  end

  it "hides the close button when show_close_button is false and no heading is given" do
    render_inline(described_class.new(show_close_button: false)) { "body" }

    expect(page).not_to have_css(".slide-over__close")
    expect(page).not_to have_css(".slide-over__header")
  end

  it "rejects unsupported widths" do
    expect { described_class.new(width: :huge) }.to raise_error(ArgumentError, /Invalid width/)
  end

  it "rejects unsupported behaviors" do
    expect { described_class.new(behavior: :persistent) }.to raise_error(ArgumentError, /:ephemeral/)
  end
end
