require "rails_helper"

RSpec.feature "DestroyRecord", type: :system do
  describe "foreign key constraints" do
    let!(:user) { create :user }
    let!(:comment) { create :comment, user: user }

    it "raises error" do
      url = "/admin/resources/users/#{user.slug}"
      visit url

      expect {
        click_on "Delete"
        confirm_alert
        wait_for_loaded
      }.not_to change(User, :count)

      expect(current_path).to eq url
      expect(page).to have_text "PG::ForeignKeyViolation"
    end
  end
end
