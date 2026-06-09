require "rails_helper"

RSpec.describe Avo::ManualFrameComponent, type: :component do
  it "renders a turbo-frame with no src, marked as a manual frame" do
    render_inline(described_class.new(
      "has_many_field_show_orders",
      deferred_url: "/admin/resources/users/1/orders?turbo_frame=has_many_field_show_orders",
      title: "Orders"
    ))

    frame = page.find("turbo-frame#has_many_field_show_orders")
    expect(frame).to be_present
    expect(frame["src"]).to be_blank
    expect(frame["loading"]).to be_blank
    expect(frame["data-manual-frame"]).not_to be_nil
    expect(frame["data-controller"]).to eq("manual-frame")
    expect(frame["data-manual-frame-url-value"]).to eq(
      "/admin/resources/users/1/orders?turbo_frame=has_many_field_show_orders"
    )
  end

  it "renders a focusable Load button labeled from the title" do
    render_inline(described_class.new(
      "has_many_field_show_orders",
      deferred_url: "/orders",
      title: "Orders"
    ))

    button = page.find("button[data-action='manual-frame#load']")
    expect(button[:"aria-label"]).to eq("Load Orders")
    expect(button).to have_text("Load Orders")
    # Native <button> elements are keyboard-focusable; ensure tabindex is not removed.
    expect(button["tabindex"]).not_to eq("-1")
  end

  it "humanizes a multi-word title for the button label" do
    render_inline(described_class.new(
      "has_many_field_show_order_items",
      deferred_url: "/order_items",
      title: "order_items"
    ))

    expect(page).to have_css("button[aria-label='Load Order items']")
    expect(page).to have_text("Load Order items")
  end

  it "renders the placeholder state markup mirroring the empty state" do
    render_inline(described_class.new(
      "has_many_field_show_orders",
      deferred_url: "/orders",
      title: "Orders"
    ))

    expect(page).to have_css("turbo-frame .state")
  end
end
