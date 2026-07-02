require "rails_helper"

# rubocop:disable Metrics/BlockLength
RSpec.describe Avo::HeaderMenuComponent, type: :component do
  def render_component(&block)
    render_inline(described_class.new, &block)
  end

  it "wraps the block content inside the row target" do
    render_component do
      "<a href='/docs' class='font-semibold'>Docs</a>".html_safe
    end

    expect(page).to have_css(
      ".header-menu[data-controller='header-menu']"
    )
    expect(page).to have_css(
      ".header-menu__row[data-header-menu-target='row'] a[href='/docs']",
      text: "Docs"
    )
  end

  it "renders the trigger button with the expected ARIA wiring" do
    render_component

    trigger = page.find(".header-menu__trigger")
    expect(trigger[:type]).to eq("button")
    expect(trigger["aria-label"]).to eq(I18n.t("avo.more"))
    expect(trigger["aria-haspopup"]).to eq("menu")
    expect(trigger["aria-expanded"]).to eq("false")
    expect(trigger["data-header-menu-target"]).to eq("trigger")
    expect(trigger["aria-controls"]).to eq(trigger["popovertarget"]).and(
      be_present
    )
  end

  it "marks the icons as aria-hidden and renders the 'more' label" do
    render_component

    hamburger =
      page.find(
        ".header-menu__trigger .header-menu__icon-hamburger",
        visible: :all
      )
    chevron =
      page.find(
        ".header-menu__trigger .color-scheme-switcher__chevron",
        visible: :all
      )
    expect(hamburger["aria-hidden"]).to eq("true")
    expect(chevron["aria-hidden"]).to eq("true")
    expect(page).to have_css(
      ".header-menu__trigger .header-menu__label-more",
      text: I18n.t("avo.more")
    )
  end

  it "renders a popover panel whose id matches the trigger's popovertarget" do
    render_component

    popover_id = page.find(".header-menu__trigger")["popovertarget"]
    expect(page).to have_css(
      "##{popover_id}[popover='auto'].popover-menu__panel",
      visible: :all
    )
  end

  it "renders the block content into both the row and the overflow target" do
    render_component do
      "<a href='/docs' class='font-semibold'>Docs</a>".html_safe
    end

    expect(page).to have_css(
      ".header-menu__row a[href='/docs']",
      text: "Docs"
    )
    expect(page).to have_css(
      ".popover-menu__panel.header-menu__popover .dropdown-menu__list a[href='/docs']",
      text: "Docs",
      visible: :all
    )
  end
end
# rubocop:enable Metrics/BlockLength
