require "rails_helper"

RSpec.feature "RecordSelectors", type: :feature do
  let!(:comment) { create :comment }
  let!(:user) { create :user }
  let!(:post) { create :post }

  it "hides the record selector" do
    visit "/admin/resources/comments"

    expect(page).not_to have_selector record_selector_checkbox_selector
  end

  it "displays the record selector" do
    visit "/admin/resources/users"

    expect(page).to have_selector record_selector_checkbox_selector
  end

  it "wires shift-select on table rows" do
    visit "/admin/resources/users"

    expect(page).to have_selector shift_selectable_checkbox_selector
  end

  it "displays the record selector on grid" do
    visit "/admin/resources/posts"

    expect(page).to have_selector record_selector_checkbox_selector
  end

  # Grid items have no table row for the controller to walk up to
  it "leaves shift-select off grid items" do
    visit "/admin/resources/posts"

    expect(page).not_to have_selector shift_selectable_checkbox_selector
  end
end
