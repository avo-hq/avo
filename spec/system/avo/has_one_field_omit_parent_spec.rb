require "rails_helper"

RSpec.describe "HasOneField omits parent record", type: :system do
  let!(:user) { create :user }
  let!(:fish) { create :fish, user: user }

  it "hides the belongs_to field pointing back to the parent on the embedded show page" do
    visit "/admin/resources/users/#{user.slug}"

    scroll_to first_tab_group

    click_tab "Fish", within_target: first_tab_group

    fish_frame = find('turbo-frame[id="has_one_field_show_fish"]')
    scroll_to fish_frame

    within fish_frame do
      # The fish record's own fields should be displayed
      expect(page).to have_text fish.name

      # The belongs_to :user field should be hidden since we're already on the user's page
      expect(page).not_to have_css('[data-field-id="user"]')
    end
  end
end
