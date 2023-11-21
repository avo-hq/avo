require "rails_helper"

RSpec.describe "Tabs", type: :system do
  let!(:user) { create :user, birthday: "10.02.1988" }

  describe "doesn't display tabs content" do
    context "on index" do
      it "doesn't display the birthday from the tab content" do
        visit "/admin/resources/users"

        expect(find("table thead").text).to eq "ID\nAVATAR\nFIRST NAME\nLAST NAME\nUSER EMAIL\nIS ACTIVE\nCV\nIS ADMIN\nROLES\nBIRTHDAY\nIS WRITER"
        within find("tr[data-resource-id='#{user.to_param}']") do
          expect(find_all("table tbody tr td")[10].text).to eq "Wednesday, 10 February 1988"
        end
      end
    end
  end

  describe "tabs" do
    context "show" do
      it "switches the tabs" do
        visit avo.resources_user_path user

        scroll_to second_tab_group

        expect(page).not_to have_selector 'turbo-frame[id="has_many_field_show_posts"]'

        click_tab "Posts", within_target: second_tab_group

        expect(find('turbo-frame[id="has_many_field_show_posts"]')).to have_text "Posts"
        expect(find('turbo-frame[id="has_many_field_show_posts"]')).to have_link "Attach post"
        expect(find('turbo-frame[id="has_many_field_show_posts"]')).to have_link "Create new post", href: "/admin/resources/posts/new?via_record_id=#{user.slug}&via_relation=user&via_relation_class=User&via_resource_class=Avo%3A%3AResources%3A%3AUser"

        click_on "Attach post"

        expect(page).to have_text "Choose post"

        click_on "Cancel"

        click_tab "Teams", within_target: first_tab_group

        expect(find("turbo-frame#has_and_belongs_to_many_field_show_teams")).to have_text "Teams"
        expect(find("turbo-frame#has_and_belongs_to_many_field_show_teams")).to have_link "Attach team"
        expect(find("turbo-frame#has_and_belongs_to_many_field_show_teams")).to have_link "Create new team", href: "/admin/resources/teams/new?via_record_id=#{user.slug}&via_relation=users&via_relation_class=User&via_resource_class=Avo%3A%3AResources%3A%3AUser"
      end

      it "hides the birthday tab" do
        visit avo.resources_user_path user

        within first_tab_group do
          expect(find('[data-target="tab-switcher"]').text).to eq "Fish\nTeams\nPeople\nSpouses\nProjects\nTeam memberships"
        end
      end
    end

    context "edit" do
      it "shows the birthday in the tab" do
        visit avo.edit_resources_user_path user

        # Birthday not visible on the first panel
        expect(find_all('[data-panel-index="0"]').first).not_to have_text "Birthday"

        scroll_to first_tab_group

        expect(first_tab_group).to have_text "Birthday"
        expect(first_tab_group).to have_selector 'input[name="user[birthday]"]', visible: false
        within first_tab_group do
          find("input", visible: true).click
        end

        find('[aria-label="February 9, 1988"]').click
        click_on "Save"
        wait_for_loaded

        expect(current_path).to eq avo.resources_user_path user
        expect(find_field_value_element("birthday")).to have_text "Tuesday, 9 February 1988"
      end

      it "hides the Projects tab" do
        visit avo.edit_resources_user_path user

        within first_tab_group do
          expect(find('[data-target="tab-switcher"]')).to have_text "Birthday\nPeople"
        end
      end

      it "only shows the Posts tab in the second group" do
        visit avo.edit_resources_user_path user

        within second_tab_group do
          expect(find('[data-target="tab-switcher"]').text).to eq "Posts"
        end
      end
    end
  end

  describe "un-authorized tabs" do
    it "hides the tab" do
      visit "/admin/resources/users/#{user.slug}"

      scroll_to first_tab_group

      within first_tab_group do
        expect(find('[data-target="tab-switcher"]')).to have_text "Fish\nTeams\nPeople\nSpouses\nProjects\nTeam memberships", exact: true
      end
    end
  end
end
