# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Attach with extra fields", type: :system do
  let!(:store) { create(:store) }
  let!(:user) { create :user }
  let!(:url) { "/admin/resources/stores/#{store.id}/patrons/new?view=show" }

  it "allows to pass in data for extra fields" do
    visit url
    expect(page).to have_selector "input#fields_review"
    expect(page).to have_selector "select#fields_related_id"

    select user.name

    expect {
      click_button "Attach"
    }.not_to change(StorePatron, :count)

    expect(page).to_not have_text "Failed to attach User"

    select user.name
    fill_in id: "fields_review", with: "Toilet paper is phenomenal here."

    expect {
      click_button "Attach"
    }.to change(StorePatron, :count).by 1
    expect(page).to have_text "User attached"
  end

  it "saves attachment adhering to options like update_using" do
    ENV["TEST_FILL_JOIN_RECORD"] = "1"
    visit url
    expect(page).to have_selector "input#fields_review"
    expect(page).to have_selector "select#fields_related_id"

    select user.name
    fill_in id: "fields_review", with: "Toilet paper is phenomenal here."

    expect {
      click_button "Attach"
    }.to change(StorePatron, :count)
    expect(store.patronships.first.review).to eq ">> Toilet paper is phenomenal here. <<"
  end
end
