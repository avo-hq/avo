require "rails_helper"

# This spec tests if the fields across multiple methods declared on the user resource are on the correct places
# It also tests if the fields and other items are in the correct order

RSpec.describe "Main menu and fields across multiple methods", type: :system do
  let(:user) { create :user }

  it "finds all test fields/tabs/sidebars where they should be" do
    ENV['testing_methods'] = "1"
    visit "/admin/resources/users/#{user.to_param}"

    #Finds heading test field
    find("[data-panel-index='1'] [data-field-id='Heading'][data-resource-show-target='headingTextWrapper']")

    # Finds main panel
    find("[data-panel-id='main'][data-panel-index='0']")

    # Verify that Heading comes before main panel
    assert_selector(:xpath, "//*[contains(@data-panel-index, '1')]//*[contains(@data-field-id, 'Heading')][contains(@data-resource-show-target, 'headingTextWrapper')]/following::*[contains(@data-panel-id, 'main')][contains(@data-panel-index, '0')]")

    # Find inside main panel test field
    show_field_wrapper(id: "Inside main panel")

    # Inside main panel
    within('[data-panel-id="main"]') do
      # Find first test sidebar
      within('[data-component-name="avo/resource_sidebar_component"][data-component-index="0"]') do
        expect(page).to have_content("Sidebar tool")

        # Find inside sidebar test field
        find("[data-field-id='Inside test_sidebar'][data-resource-show-target='inside testSidebarTextWrapper']")
      end

      # Find user sidebar
      within('[data-component-name="avo/resource_sidebar_component"][data-component-index="1"]') do
        # Find inside main panel sidebar test field
        find("[data-field-id='Inside main_panel_sidebar'][data-resource-show-target='inside mainPanelSidebarTextWrapper']")
      end
    end

    # Inside user information panel
    within('[data-panel-index="3"]') do
      # Find inside panel test field
      find("[data-field-id='Inside panel'][data-resource-show-target='inside panelTextWrapper']")

      # Inside row component
      within('[data-component="Avo::RowComponent"]') do
        find("[data-field-id='Inside panel -> row'][data-resource-show-target='inside panel > rowTextWrapper']")
      end

       # Find panel test first sidebar
      within('[data-component-name="avo/resource_sidebar_component"][data-component-index="0"]') do
        # Find inside panel inside sidebar test field
        find("[data-field-id='Inside panel -> sidebar'][data-resource-show-target='inside panel > sidebarTextWrapper']")
      end

      # Find panel test second sidebar
      within('[data-component-name="avo/resource_sidebar_component"][data-component-index="1"]') do
        # Find inside panel inside second sidebar test field
        find("[data-field-id='Inside panel -> sidebar 2'][data-resource-show-target='inside panel > sidebar 2TextWrapper']")

        expect(page).to have_text("🪧 This sidebar partial is waiting to be updated")
      end
    end


    # Tabs
    within("#avo-resources-items-tabgroup-4-avo-resources-items-tab-test_tab") do
      within('[data-target="tab-switcher"]') do
        expect(page).to have_text("test_tab")
        expect(page).to have_text("Inside tabs")
        expect(page).to have_text("Fish")
      end

      # Find Inside tabs -> tab -> panel test field
      find("[data-field-id='Inside tabs -> tab -> panel'][data-resource-show-target='inside tabs > tab > panelTextWrapper']")

      # Find Inside tabs -> tab test field
      find("[data-field-id='Inside tabs -> tab'][data-resource-show-target='inside tabs > tabTextWrapper']")
    end

    ENV['testing_methods'] = nil
  end
end
