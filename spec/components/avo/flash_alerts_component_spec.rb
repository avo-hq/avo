require "rails_helper"

RSpec.describe Avo::FlashAlertsComponent, type: :component do
  it "uses default timeout when timeout is not set" do
    flashes = {
      notice: "Simple message",
      success: {
        body: "Default timeout"
      }
    }

    with_controller_class Avo::BaseController do
      render_inline(described_class.new(flashes: flashes))

      expect(page).to have_css("div[data-controller='alert']", text: "Simple message")
      expect(page).to have_css("div[data-controller='alert']", text: "Default timeout")

      # Should auto-dismiss with default timeout
      alert_with_default_timeout = page.all("div[data-controller='alert']")
      alert_with_default_timeout.each do |alert|
        expect(alert["data-alert-dismiss-after-value"]).to eq Avo.configuration.alert_dismiss_time.to_s
      end
    end
  end

  it "overrides the default timeout when timeout is set" do
    flashes = {
      notice: {
        body: "Message with custom timeout",
        timeout: 10000
      }
    }

    with_controller_class Avo::BaseController do
      render_inline(described_class.new(flashes: flashes))

      expect(page).to have_css("div[data-controller='alert']", text: "Message with custom timeout")

      # Should auto-dismiss with custom timeout
      alert_with_custom_timeout = page.all("div[data-controller='alert']").find { |alert| alert.text.include?("Message with custom timeout") }
      expect(alert_with_custom_timeout["data-alert-dismiss-after-value"]).to eq "10000"
    end
  end

  it "does not auto-dismiss when timeout is :forever" do
    flashes = {
      notice: {
        body: "Message with no timeout",
        timeout: :forever
      }
    }

    with_controller_class Avo::BaseController do
      render_inline(described_class.new(flashes: flashes))

      expect(page).to have_css("div[data-controller='alert']", text: "Message with no timeout")
      # Should NOT auto-dismiss
      expect(page).not_to have_css("div[data-alert-dismiss-after-value]")
    end
  end

  it "handles multiple flash messages" do
    flashes = {
      notice: "Simple notice",
      success: {
        body: "Default timeout"
      },
      alert: {
        body: "No timeout",
        timeout: :forever
      },
      error: {
        body: "Custom timeout",
        timeout: 10000
      }
    }

    with_controller_class Avo::BaseController do
      render_inline(described_class.new(flashes: flashes))

      expect(page).to have_css("div[data-controller='alert']", text: "Simple notice")
      expect(page).to have_css("div[data-controller='alert']", text: "Default timeout")
      expect(page).to have_css("div[data-controller='alert']", text: "No timeout")
      expect(page).to have_css("div[data-controller='alert']", text: "Custom timeout")
      # Count the number of alerts with and without auto-dismiss (Simple notice and Error message)
      expect(page).to have_css("div[data-alert-dismiss-after-value]", count: 3)

      # Find the specific alert that should not auto-dismiss (Alert with no timeout)
      alert_with_no_timeout = page.find("div[data-controller='alert']", text: "No timeout")
      expect(alert_with_no_timeout["data-alert-dismiss-after-value"]).to be_nil
    end
  end

  it "uses default timeout when invalid timeout is provided" do
    flashes = {
      notice: {
        body: "Invalid timeout",
        timeout: "invalid"
      }
    }

    with_controller_class Avo::BaseController do
      render_inline(described_class.new(flashes: flashes))

      alert_with_default_timeout = page.find("div[data-controller='alert']", text: "Invalid timeout")
      expect(alert_with_default_timeout["data-alert-dismiss-after-value"]).to eq Avo.configuration.alert_dismiss_time.to_s
    end
  end
end
