require "rails_helper"

RSpec.feature "ModelErrors", type: :system do
  let(:comment) { create :comment }

  around do |example|
    Comment.before_destroy do
      errors.add(:base, "Some Errors")

      throw(:abort)
    end

    example.run

    Comment.before_destroy do
      false
    end
  end

  it "does not swallow errors" do
    visit "/admin/resources/comments/#{comment.id}"

    accept_alert do
      click_on "Delete"
    end
    wait_for_loaded

    expect(page).to have_text "Some Errors"
  end
end
