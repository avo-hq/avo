require "rails_helper"

RSpec.describe TenantSwitcherComponentPreview, type: :component do
  it "names the current account on the trigger, marks it in the list and hides a single account" do
    render_preview(:default, from: described_class)

    expect(page).to have_css(".tenant-switcher", count: 3)
    expect(page).to have_css(".tenant-switcher__trigger[aria-label='Switch account. Current account: Apple']")
    expect(page).to have_css(".tenant-switcher__item[aria-current='true']", text: "Apple", visible: :all)
    expect(page).not_to have_css(".tenant-switcher__item[aria-current='true']", text: "Google", visible: :all)
  end

  it "keeps rendering the sidebar when an account has a blank name" do
    tenants = [described_class::Tenant.new(1, ""), described_class::Tenant.new(2, "Google")]

    render_inline(Avo::TenantSwitcherComponent.new(tenants:, current: tenants.first))

    expect(page).to have_css(".tenant-switcher__trigger .cado-avatar__initials", text: "#")
  end
end
