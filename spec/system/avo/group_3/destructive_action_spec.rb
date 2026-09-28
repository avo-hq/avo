require "rails_helper"

RSpec.describe "Destructive actions", type: :system do
  let!(:comment) { create :comment, commentable: create(:post) }
  let(:confirm_button) { find("[role='dialog'] [data-target='submit_action']") }

  it "only runs after the user types the confirmation text" do
    visit "/admin/resources/photo_comments"
    check_select_all
    open_panel_action(action_name: "Delete")

    expect(page).to have_text "Type delete to confirm"
    expect(confirm_button).to be_disabled
    expect(confirm_button[:class]).to include "button--color-red"

    fill_in "destructive_action_confirmation", with: "delet"
    expect(confirm_button).to be_disabled

    find_field("destructive_action_confirmation").send_keys(:enter)
    find_field("destructive_action_confirmation").send_keys([:control, :enter])
    expect(page).to have_css("[role='dialog']")
    expect(Comment.exists?(comment.id)).to be true

    fill_in "destructive_action_confirmation", with: "delete"
    expect(confirm_button).not_to be_disabled

    run_action

    expect(Comment.exists?(comment.id)).to be false
  end

  it "shows the modal even when confirmation is turned off" do
    Avo::Actions::DeleteComment.confirmation = false
    visit "/admin/resources/photo_comments/#{comment.id}"
    open_panel_action(action_name: "Delete")

    expect(confirm_button).to be_disabled
    expect(Comment.exists?(comment.id)).to be true
  ensure
    Avo::Actions::DeleteComment.confirmation = true
  end

  it "leaves other actions as they are" do
    visit "/admin/resources/users"
    open_panel_action(action_name: "Dummy action")

    expect(page).not_to have_field "destructive_action_confirmation"
    expect(confirm_button).not_to be_disabled
    expect(confirm_button[:class]).not_to include "button--color-red"
  end
end
