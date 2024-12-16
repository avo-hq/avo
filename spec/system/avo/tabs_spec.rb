require "rails_helper"

RSpec.describe "Tabs", type: :system do
  let!(:user) { create :user, birthday: "10.02.1988" }
  let!(:projects) { create_list :project, 9, users: [user] }

  describe "doesn't display tabs content" do
    context "on index" do
      it "doesn't display the birthday from the tab content" do
        visit "/admin/resources/users"

        expect(find("table thead").text).to eq "Select all\n\t\nID\n\t\nAVATAR\n\t\nFIRST NAME\n\t\nLAST NAME\n\t\nUSER EMAIL\n\t\nIS ACTIVE\n\t\nCV\n\t\nIS ADMIN\n\t\nROLES\n\t\nPERMISSIONS\n\t\nBIRTHDAY\n\t\nIS WRITER"
        within find("tr[data-resource-id='#{user.to_param}']") do
          expect(find_all("table tbody tr td")[11].text).to eq "Wednesday, 10 February 1988"
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

        expect(page).to have_text "First tabs group"
        expect(page).to have_text "First tabs group description"

        expect(page).to have_text "Second tabs group"
        expect(page).to have_text "Second tabs group description"

        click_on "Attach post"

        expect(page).to have_text "Choose post"

        click_on "Cancel"

        click_tab "Teams", within_target: first_tab_group
        scroll_to teams_frame = find("turbo-frame#has_and_belongs_to_many_field_show_teams")

        expect(teams_frame).to have_text "Teams"
        expect(teams_frame).to have_link "Attach team"
        expect(teams_frame).to have_link "Create new team", href: "/admin/resources/teams/new?via_record_id=#{user.slug}&via_relation=admin&via_relation_class=User&via_resource_class=Avo%3A%3AResources%3A%3AUser"
      end

      it "hides the birthday tab" do
        visit avo.resources_user_path user

        within first_tab_group do
          expect(find('[data-tabs-target="tabSwitcher"]').text).to eq "Fish\nTeams\nPeople\nSpouses\nProjects\nTeam memberships\nCreated at"
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
        save

        expect(page).to have_current_path avo.resources_user_path(user)
        expect(find_field_value_element("birthday")).to have_text "Tuesday, 9 February 1988"
      end

      it "hides the Projects tab" do
        visit avo.edit_resources_user_path user

        within first_tab_group do
          expect(find('[data-tabs-target="tabSwitcher"]')).to have_text "Birthday\nPeople"
        end
      end

      it "only shows the Posts tab in the second group" do
        visit avo.edit_resources_user_path user

        within second_tab_group do
          expect(find('[data-tabs-target="tabSwitcher"]').text).to eq "Posts"
        end
      end
    end
  end

  describe "un-authorized tabs" do
    it "hides the tab" do
      visit "/admin/resources/users/#{user.slug}"

      scroll_to first_tab_group

      within first_tab_group do
        expect(find('[data-tabs-target="tabSwitcher"]')).to have_text "Fish\nTeams\nPeople\nSpouses\nProjects\nTeam memberships\nCreated at", exact: true
      end
    end
  end

  describe "durable tabs" do
    it "keeps same tab between show and edit" do
      visit "/admin/resources/users/#{user.slug}"

      # Fish tab is selected
      find('a[data-selected="true"][data-tabs-tab-name-param="Fish"]')
      # Click on Team memberships tab
      find('a[data-selected="false"][data-tabs-tab-name-param="Team memberships"]').click

      # Team memberships tab is selected now and Fish tab is not
      find('a[data-selected="false"][data-tabs-tab-name-param="Fish"]')
      find('a[data-selected="true"][data-tabs-tab-name-param="Team memberships"]')

      click_on "Edit"

      # On edit page, Birthday tab and Posts is selected
      find('a[data-selected="true"][data-tabs-tab-name-param="Birthday"]')
      find('a[data-selected="true"][data-tabs-tab-name-param="Posts"]')

      click_on "Cancel"

      # On show page, Team memberships tab still selected
      find('a[data-selected="false"][data-tabs-tab-name-param="Fish"]')
      find('a[data-selected="true"][data-tabs-tab-name-param="Team memberships"]')
      # Click on People tab
      find('a[data-selected="false"][data-tabs-tab-name-param="People"]').click

      click_on "Edit"

      # On edit page, People instead Birthday tab and Posts is selected
      find('a[data-selected="true"][data-tabs-tab-name-param="People"]')
      find('a[data-selected="true"][data-tabs-tab-name-param="Posts"]')
    end
  end

  describe "tabs with names that have spaces" do
    it "keeps tab on reload" do
      visit avo.resources_user_path user

      find('a[data-selected="true"][data-tabs-tab-name-param="Fish"]')
      find('a[data-selected="false"][data-tabs-tab-name-param="Projects"]').click
      find('a[data-selected="false"][data-tabs-tab-name-param="Team memberships"]')

      refresh

      find('a[data-selected="false"][data-tabs-tab-name-param="Fish"]')
      find('a[data-selected="true"][data-tabs-tab-name-param="Projects"]')
      find('a[data-selected="false"][data-tabs-tab-name-param="Team memberships"]').click

      refresh

      find('a[data-selected="false"][data-tabs-tab-name-param="Fish"]')
      find('a[data-selected="false"][data-tabs-tab-name-param="Projects"]')
      find('a[data-selected="true"][data-tabs-tab-name-param="Team memberships"]')
    end
  end

  it "date_time field works on tabs" do
    visit avo.resources_user_path user

    find('a[data-selected="false"][data-tabs-tab-name-param="Main comment"]').click
    expect(page).not_to have_text 'Invalid DateTime'

    find('a[data-selected="false"][data-tabs-tab-name-param="Created at"]').click
    expect(page).not_to have_text 'Invalid DateTime'
  end

  it "keeps the pagination on tab when back is used" do
    visit avo.resources_user_path user

    find('a[data-selected="false"][data-tabs-tab-name-param="Projects"]').click
    expect(page).to have_css('a.current[role="link"][aria-disabled="true"][aria-current="page"]', text: "1")
    expect(page).to have_text "Displaying items 1-8 of 9 in total"

    find('a[data-turbo-frame="has_and_belongs_to_many_field_show_projects"]', text: "2").click
    expect(page).to have_css('a.current[role="link"][aria-disabled="true"][aria-current="page"]', text: "2")
    expect(page).to have_text "Displaying items 9-9 of 9 in total"

    find('a[aria-label="View project"]').click
    wait_for_loaded

    page.go_back
    wait_for_loaded

    expect(page).to have_css('a.current[role="link"][aria-disabled="true"][aria-current="page"]', text: "2")
    expect(page).to have_text "Displaying items 9-9 of 9 in total"
  end

  it "keeps the per_page on association when back is used" do
    default_cache_associations_pagination_value = Avo.configuration.cache_associations_pagination
    Avo.configuration.cache_associations_pagination = true
    visit avo.resources_user_path user

    find('a[data-selected="false"][data-tabs-tab-name-param="Projects"]').click
    within("#has_and_belongs_to_many_field_show_projects") do
      expect(page).to have_text "Displaying items 1-8 of 9 in total"
      find("select#per_page.appearance-none").select("24")
    end

    expect(page).to have_text "Displaying 9 items"
    expect(find("select#per_page.appearance-none").find("option[selected]").text).to eq("24")

    find_all('a[aria-label="View project"]')[0].click
    wait_for_loaded

    page.go_back
    wait_for_loaded

    expect(page).to have_text "Displaying 9 items"
    expect(find("select#per_page.appearance-none").find("option[selected]").text).to eq("24")
    Avo.configuration.cache_associations_pagination = default_cache_associations_pagination_value
  end
end
