require 'rails_helper'

RSpec.feature "RecordSelectors", type: :feature do
  let!(:comment) { create :comment }
  let!(:user) { create :user }
  let!(:post) { create :post }

  it "hides the record selector" do
    visit "/admin/resources/comments"

    expect(page).not_to have_selector 'input[type="checkbox"][data-action="input->item-selector#toggle input->item-select-all#selectRow"]'
  end

  it "displays the record selector" do
    visit "/admin/resources/users"

    expect(page).to have_selector 'input[type="checkbox"][data-action="input->item-selector#toggle input->item-select-all#selectRow"]'
  end

  it "displays the record selector on grid" do
    visit "/admin/resources/posts"

    expect(page).to have_selector 'input[type="checkbox"][data-action="input->item-selector#toggle input->item-select-all#selectRow"]'
  end
end
