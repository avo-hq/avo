require "rails_helper"

RSpec.describe "HasOneField linkable title", type: :system do
  let!(:user) { create :user }
  let!(:fish) { create :fish, user: user }

  it "renders the panel title as a link when linkable is true" do
    visit "/admin/resources/users/#{user.slug}"

    scroll_to first_tab_group

    click_tab "Fish", within_target: first_tab_group

    fish_frame = find('turbo-frame[id="has_one_field_show_fish"]')
    scroll_to fish_frame

    within fish_frame do
      # The panel title should be a link since linkable: true
      panel_header = find('[data-target="title"]')
      link = panel_header.find("a")

      # The link should point to the fish show page without the turbo_frame param
      expect(link[:href]).to include("/fish/")
      expect(link[:href]).not_to include("turbo_frame=")
      expect(link[:target]).to eq("_blank")
    end
  end
end
