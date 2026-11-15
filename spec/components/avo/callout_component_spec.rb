require "rails_helper"

RSpec.describe Avo::CalloutComponent, type: :component do
  it "renders an info callout by default" do
    render_inline(described_class.new(title: "Heads up", body: "Projects sync every night."))

    expect(page).to have_css("div.callout.callout--info")
    expect(page).to have_css(".callout__icon")
    expect(page).to have_css(".callout__title", text: "Heads up")
    expect(page).to have_css(".callout__body", text: "Projects sync every night.")
    expect(page).not_to have_css("a.callout")
  end

  it "renders a link when it has a url" do
    render_inline(described_class.new(type: :success, title: "Billing", url: "/billing", target: :_blank))

    expect(page).to have_css("a.callout.callout--success.callout--link[href='/billing'][target='_blank']")
    expect(page).not_to have_css(".callout__body")
  end

  it "renders safe HTML in the body and escapes the rest" do
    render_inline(described_class.new(body: "<b>Bold</b>".html_safe, title: "<i>Plain</i>"))

    expect(page).to have_css(".callout__body b", text: "Bold")
    expect(page).not_to have_css(".callout__title i")
    expect(page).to have_css(".callout__title", text: "<i>Plain</i>")
  end

  it "drops the icon with icon: false" do
    render_inline(described_class.new(type: :error, title: "Locked", icon: false))

    expect(page).to have_css(".callout.callout--error")
    expect(page).not_to have_css(".callout__icon")
  end

  it "renders nothing without a title or a body" do
    render_inline(described_class.new(type: :warning, icon: "tabler/outline/flag"))

    expect(page).not_to have_css(".callout")
  end

  it "picks the icon that matches the type unless one is given" do
    component = described_class.new(type: :warning, title: "Careful")
    expect(component.icon).to eq("tabler/outline/exclamation-circle")

    component = described_class.new(type: :warning, title: "Careful", icon: "tabler/outline/flag")
    expect(component.icon).to eq("tabler/outline/flag")
  end
end
