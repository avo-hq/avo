require "rails_helper"

RSpec.describe Avo::AlertComponent, type: :component do
  it "renders the default alert with description" do
    render_inline(described_class.new(
      :default,
      "Your account has been successfully created.",
      description: "Message"
    ))

    expect(page).to have_css(".alert.alert--default")
    expect(page).to have_css(".alert__icon")
    expect(page).to have_css(".alert__title", text: "Your account has been successfully created.")
    expect(page).to have_css(".alert__message", text: "Message")
    expect(page).to have_css("button.alert__icon-container--close[aria-label='Close alert'][data-action='alert#close']")
  end

  it "maps error alerts to the danger variant" do
    render_inline(described_class.new(:error, "Something went wrong"))

    expect(page).to have_css(".alert.alert--danger")
    expect(page).not_to have_css(".alert__message")
  end

  it "maps notice alerts to the info variant" do
    render_inline(described_class.new(:notice, "Heads up"))

    expect(page).to have_css(".alert.alert--info")
  end

  it "does not add auto-dismiss when timeout is forever" do
    render_inline(described_class.new(:success, "Saved successfully", timeout: :forever))

    expect(page).to have_css(".alert[data-controller='alert']")
    expect(page).not_to have_css(".alert[data-alert-dismiss-after-value]")
  end

  it "falls back to the configured timeout for invalid values" do
    render_inline(described_class.new(:success, "Saved successfully", timeout: "invalid"))

    alert = page.find(".alert[data-controller='alert']", text: "Saved successfully")
    expect(alert["data-alert-dismiss-after-value"]).to eq Avo.configuration.alert_dismiss_time.to_s
  end

  it "renders hidden when the message is nil" do
    render_inline(described_class.new(:success, nil))

    expect(page).to have_css(".hidden", visible: false)
  end
end
