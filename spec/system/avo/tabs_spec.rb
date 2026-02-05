require "rails_helper"

RSpec.describe "Tabs", type: :system do
  let!(:user) { create :user, birthday: "10.02.1988" }
  let!(:projects) { create_list :project, 9, users: [user] }

  describe "doesn't display tabs content" do
    context "on index" do
      it "doesn't display the birthday from the tab content" do
        visit "/admin/resources/users"

        expect(strip_html(find("table thead").text)).to eq "Select all ID Gravatar First name Last name User Email Is active CV Is admin Roles Permissions Birthday Is writer"
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
          expect(strip_html(find('[role="tablist"]').text)).to eq "Fish Teams People Spouses Projects Team memberships Created at"
        end
      end
    end

    context "edit" do
      it "shows the birthday in the tab" do
        visit avo.edit_resources_user_path user

        # Birthday not visible on the first panel
        expect(find_all('[data-item-index="0"]').first).not_to have_text "Birthday"

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
          expect(find('[role="tablist"]')).to have_text "Birthday\nPeople"
        end
      end

      it "only shows the Posts tab in the second group" do
        visit avo.edit_resources_user_path user

        within second_tab_group do
          expect(find('[role="tablist"]').text).to eq "Posts"
        end
      end
    end
  end

  describe "un-authorized tabs" do
    it "hides the tab" do
      visit "/admin/resources/users/#{user.slug}"

      scroll_to first_tab_group

      within first_tab_group do
        expect(strip_html(find('[role="tablist"]').text)).to eq "Fish Teams People Spouses Projects Team memberships Created at"
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
    expect(page).not_to have_text "Invalid DateTime"

    find('a[data-selected="false"][data-tabs-tab-name-param="Created at"]').click
    expect(page).not_to have_text "Invalid DateTime"
  end

  it "keeps the pagination on tab when back is used" do
    Avo.configuration.persistence = {driver: :session}

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

    scroll_to find('a[data-tabs-tab-name-param="Projects"]')
    expect(page).to have_css('a.current[role="link"][aria-disabled="true"][aria-current="page"]', text: "2")
    expect(page).to have_text "Displaying items 9-9 of 9 in total"

    Avo.configuration.persistence = {driver: nil}
  end

  it "keeps the per_page on association when back is used" do
    Avo.configuration.persistence = {driver: :session}

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

    scroll_to find('a[data-tabs-tab-name-param="Projects"]')
    expect(page).to have_text "Displaying 9 items"
    expect(find("select#per_page.appearance-none").find("option[selected]").text).to eq("24")

    Avo.configuration.persistence = {driver: nil}
  end

  let!(:person) { create :person }

  it "lazy_load" do
    visit avo.resources_person_path(person)

    scroll_to first_tab_group

    # Find visible information from first default tab
    field_wrapper = find('div[data-field-id="company"]')
    label = field_wrapper.find('div[data-slot="label"]')
    value = field_wrapper.find('div[data-slot="value"]')
    expect(label.text.strip).to eq("Company")
    expect(value.text.strip).to eq("TechCorp Inc.")

    # Expect text from preferences and employment tabs (not lazy loaded) to be visible
    within(:css, '.block.hidden[data-tabs-target="tabPanel"][data-tab-id="Preferences"]', visible: :all) do
      # Find the field wrapper for "Notification preference"
      field_wrapper = find('div[data-field-id="notification_preference"]', visible: :all)

      # Locate the label and value within the wrapper
      label = field_wrapper.find('div[data-slot="label"]', visible: :all)
      value = field_wrapper.find('div[data-slot="value"]', visible: :all)

      expect(label.text(:all).strip).to eq("Notification preference")
      expect(value.text(:all).strip).to eq("Email & SMS")
    end

    # Expect not to find field from lazy loaded tab
    within(:css, '.block.hidden[data-tabs-target="tabPanel"][data-tab-id="Address"]', visible: :all) do
      expect(page).not_to have_selector('div[data-field-id="phone_number"]', visible: :all)
    end

    find('a[data-selected="false"][data-tabs-tab-name-param="Address"]').click
    wait_for_loaded

    # Find the phone number from lazy loaded tab after clicking on it
    within(:css, '.block[data-tabs-target="tabPanel"][data-tab-id="Address"]', visible: :all) do
      # Find the field wrapper for "Phone number"
      field_wrapper = find('div[data-field-id="phone_number"]', visible: :all)

      # Locate the label and value within the wrapper
      label = field_wrapper.find('div[data-slot="label"]', visible: :all)
      value = field_wrapper.find('div[data-slot="value"]', visible: :all)

      expect(label.text(:all).strip).to eq("Phone number")
      expect(value.text(:all).strip).to eq("+1 (555) 123-4567")
    end
  end

  describe "tabs with non-ASCII names" do
    let!(:user) { create :user }

    it "renders the correct turbo frame content for tabs with non-ascii names" do
      # Set up temporary field for User
      Avo::Resources::User.with_temporary_items do
        field :name
        tabs do
          tab "其他store", lazy_load: true do
            field :tab_1 do
              "tab_1"
            end
          end

          tab "store 🧭", lazy_load: true do
            field :tab_2 do
              "tab_2"
            end
          end

          tab "📖 store", lazy_load: true do
            field :tab_3 do
              "tab_3"
            end
          end
        end
      end

      # Visit page
      visit avo.resources_user_path(user)

      # Click on first tab and verify that the right turbo frame content is rendered
      find('a[data-tabs-tab-name-param="其他store"]').click
      wait_for_loaded
      within(find("turbo-frame", id: /avo-resources-items-tab-#{Digest::MD5.hexdigest("其他store")}/)) do
        expect(page).to have_text("tab_1")
        expect(page).not_to have_text("tab_2")
        expect(page).not_to have_text("tab_3")
      end

      # Click on second tab and verify that the right turbo frame content is rendered
      find('a[data-tabs-tab-name-param="store 🧭"]').click
      wait_for_loaded
      within(find("turbo-frame", id: /avo-resources-items-tab-#{Digest::MD5.hexdigest("store 🧭")}/)) do
        expect(page).to have_text("tab_2")
        expect(page).not_to have_text("tab_1")
        expect(page).not_to have_text("tab_3")
      end

      # Click on third tab and verify that the right turbo frame content is rendered
      find('a[data-tabs-tab-name-param="📖 store"]').click
      wait_for_loaded
      within(find("turbo-frame", id: /avo-resources-items-tab-#{Digest::MD5.hexdigest("📖 store")}/)) do
        expect(page).to have_text("tab_3")
        expect(page).not_to have_text("tab_1")
        expect(page).not_to have_text("tab_2")
      end

      Avo::Resources::User.restore_items_from_backup
    end
  end
end
