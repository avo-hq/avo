require "rails_helper"

RSpec.describe Avo::FlashAlertsComponent, type: :component do
  it "renders a simple string message" do
    flashes = {notice: "Simple message"}

    with_controller_class Avo::BaseController do
      render_inline(described_class.new(flashes: flashes))

      expect(page).to have_css("div[data-controller='alert']", text: "Simple message")
      # Should auto-dismiss
      expect(page).to have_css("div[data-alert-dismiss-after-value]")
    end
  end

  it "renders a hash message with keep_open: false" do
    flashes = {
      notice: {
        body: "Message with keep_open false",
        keep_open: false
      }
    }

    with_controller_class Avo::BaseController do
      render_inline(described_class.new(flashes: flashes))

      expect(page).to have_css("div[data-controller='alert']", text: "Message with keep_open false")
      # Should auto-dismiss
      expect(page).to have_css("div[data-alert-dismiss-after-value]")
    end
  end

  it "renders a hash message with keep_open: true" do
    flashes = {
      notice: {
        body: "Message with keep_open true",
        keep_open: true
      }
    }

    with_controller_class Avo::BaseController do
      render_inline(described_class.new(flashes: flashes))

      expect(page).to have_css("div[data-controller='alert']", text: "Message with keep_open true")
      # Should NOT auto-dismiss
      expect(page).not_to have_css("div[data-alert-dismiss-after-value]")
    end
  end

  it "handles multiple flash messages" do
    flashes = {
      notice: "Simple notice",
      alert: {
        body: "Alert with keep_open",
        keep_open: true
      },
      error: {
        body: "Error message",
        keep_open: false
      }
    }

    with_controller_class Avo::BaseController do
      render_inline(described_class.new(flashes: flashes))

      expect(page).to have_css("div[data-controller='alert']", text: "Simple notice")
      expect(page).to have_css("div[data-controller='alert']", text: "Alert with keep_open")
      expect(page).to have_css("div[data-controller='alert']", text: "Error message")

      # Count the number of alerts with and without auto-dismiss (Simple notice and Error message)
      expect(page).to have_css("div[data-alert-dismiss-after-value]", count: 2)

      # Find the specific alert that should not auto-dismiss (Alert with keep_open)
      alert_with_keep_open = page.find("div[data-controller='alert']", text: "Alert with keep_open")
      expect(alert_with_keep_open["data-alert-dismiss-after-value"]).to be_nil
    end
  end
end
