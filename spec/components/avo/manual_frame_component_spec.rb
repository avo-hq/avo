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

  it "uses the title verbatim without mangling custom/translated names" do
    # Callers pass already display-ready names (field.plural_name / tab.title);
    # the component must not `humanize` them (which would downcase "Order Items").
    render_inline(described_class.new(
      "has_many_field_show_order_items",
      deferred_url: "/order_items",
      title: "Order Items"
    ))

    expect(page).to have_css("button[aria-label='Load Order Items']")
    expect(page).to have_text("Load Order Items")
  end

  it "renders an action-bar placeholder with the title" do
    render_inline(described_class.new(
      "has_many_field_show_orders",
      deferred_url: "/orders",
      title: "Orders"
    ))

    placeholder = page.find("[data-manual-frame-target='placeholder']")
    expect(placeholder[:class]).to include("manual-frame")
    expect(placeholder).to have_text("Orders")
  end

  it "renders a hidden loading backdrop overlay" do
    render_inline(described_class.new(
      "has_many_field_show_orders",
      deferred_url: "/orders",
      title: "Orders"
    ))

    loading = page.find("[data-manual-frame-target='loading']", visible: false)
    expect(loading[:class]).to include("manual-frame__overlay")
    expect(loading["hidden"]).not_to be_nil
    expect(loading).to have_text("Loading")
  end

  it "shows the description beside the title when one is present" do
    render_inline(described_class.new(
      "has_many_field_show_orders",
      deferred_url: "/orders",
      title: "Orders",
      description: "All recent orders"
    ))

    expect(page.find("[data-manual-frame-target='placeholder']")).to have_text("All recent orders")
  end

  it "omits the description when none is given" do
    render_inline(described_class.new(
      "has_many_field_show_orders",
      deferred_url: "/orders",
      title: "Orders"
    ))

    # Only the title text, no stray description span.
    expect(page.find("[data-manual-frame-target='placeholder']").text.strip).to eq("Orders Load Orders")
  end

  it "renders a hidden error/Retry state" do
    render_inline(described_class.new(
      "has_many_field_show_orders",
      deferred_url: "/orders",
      title: "Orders"
    ))

    # The error state is present but hidden until the controller reveals it.
    error = page.find("[data-manual-frame-target='error']", visible: false)
    expect(error["hidden"]).not_to be_nil
    expect(error[:class]).to include("manual-frame")
    expect(error).to have_text("Couldn't load Orders")
  end

  it "renders a Retry button wired to the retry action, labeled from the title" do
    render_inline(described_class.new(
      "has_many_field_show_orders",
      deferred_url: "/orders",
      title: "Orders"
    ))

    button = page.find("button[data-action='manual-frame#retry']", visible: false)
    expect(button[:"aria-label"]).to eq("Retry Orders")
    expect(button).to have_text("Retry")
  end
end
