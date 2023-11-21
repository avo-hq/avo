# EXTRACT:
# require "rails_helper"

# RSpec.describe "DynamicFilters", type: :system do
#   let!(:apple) { create :team, name: "Apple", team_members: [admin] }
#   let!(:tesla) { create :team, name: "Tesla", team_members: [admin] }
#   let!(:amazon) { create :team, name: "Amazon", team_members: [admin] }
#   let!(:netflix) { create :team, name: "Netflix", team_members: [admin] }

#   describe "with filters bar expanded" do
#     around do |example|
#       initial_value = Avo::DynamicFilters.configuration.always_expanded
#       Avo::DynamicFilters.configuration.always_expanded = true
#       Avo::DynamicFilters.configuration.button_label = "Feelters"
#       example.run
#       Avo::DynamicFilters.configuration.always_expanded = initial_value
#     end

#     it "keeps the filters panel expanded" do
#       visit "/admin/resources/teams"

#       expect(page).not_to have_text "Feelters"
#       expect(page).to have_text "Add filter"
#       expect(page).to have_css '[data-avo-filters-target="add-filter-button"]'
#     end
#   end
#   describe "with filters bar collapsed" do
#     around do |example|
#       initial_value = Avo::DynamicFilters.configuration.always_expanded
#       Avo::DynamicFilters.configuration.always_expanded = false
#       Avo::DynamicFilters.configuration.button_label = "Feelters"
#       example.run
#       Avo::DynamicFilters.configuration.always_expanded = initial_value
#     end

#     describe "the button label is visible" do
#       it "shows the filters button" do
#         visit "/admin/resources/teams"

#         expect(page).to have_text "Feelters"

#         expect(page).to have_text "Apple"
#         expect(page).to have_text "Tesla"
#         expect(page).to have_text "Amazon"
#         expect(page).to have_text "Netflix"
#       end

#       it "expands the filters bar" do
#         visit "/admin/resources/teams"

#         expect(page).not_to have_text "Add filter"

#         # Test opening of the panel
#         click_on "Feelters"

#         expect(page).to have_text "Add filter"
#         expect(page).to have_css '[data-avo-filters-target="add-filter-button"]'

#         # Test filters panel open
#         within(filters_dropdown_panel) do
#           expect(page).to have_link "Id"
#           expect(page).to have_link "Name"
#           expect(page).to have_link "Created at"
#           expect(page).to have_link "Description"
#           expect(page).to have_link "Memberships"
#         end

#         # Test adding a filter
#         add_filter "Id"

#         within(filters_holder) do
#           expect(page).to have_text "Id"
#           expect(page).to have_text "Filter by Id"
#           expect(page).to have_select "condition"
#           expect(page).to have_css 'input[data-action="keydown.enter->avo-filters#apply"]'
#         end

#         # Test updating the filter value and applying it
#         fill_filter_value "id", with: amazon.id
#         apply_filter "id"

#         expect(page).to have_text "Amazon"
#         expect(page).not_to have_text "Apple"
#         expect(page).not_to have_text "Tesla"
#         expect(page).not_to have_text "Netflix"

#         # Test filter pill content
#         expect(filter_pill("Id")).to have_text "Id\nis \"#{amazon.id}\""

#         # Test removing a filter
#         remove_filter "Id"

#         expect(page).to have_text "Apple"
#         expect(page).to have_text "Tesla"
#         expect(page).to have_text "Amazon"
#         expect(page).to have_text "Netflix"

#         # The filter panel will be collapsed now because there are no filters present
#         click_on "Feelters"

#         expect(filters_holder.text).to eq ""

#         add_filter "Name"
#         fill_filter_value "Name", with: "Netflix"
#         apply_filter "Name"

#         expect(page).not_to have_text "Apple"
#         expect(page).not_to have_text "Tesla"
#         expect(page).not_to have_text "Amazon"
#         expect(page).to have_text "Netflix"

#         click_on "Reset filters"

#         expect(page).to have_text "Apple"
#         expect(page).to have_text "Tesla"
#         expect(page).to have_text "Amazon"
#         expect(page).to have_text "Netflix"
#       end
#     end
#   end

#   describe "with filters bar visible" do
#     around do |example|
#       initial_value = Avo::DynamicFilters.configuration.always_expanded
#       Avo::DynamicFilters.configuration.always_expanded = true
#       Avo::DynamicFilters.configuration.button_label = "Feelters"
#       example.run
#       Avo::DynamicFilters.configuration.always_expanded = initial_value
#     end

#     describe "the button label is visible" do
#       it "hehe" do
#         visit "/admin/resources/teams"
#         expect(page).not_to have_text "Feelters"
#       end
#     end
#   end
# end

# def filters_dropdown_panel
#   find ".filters-dropdown-selector"
# end

# def add_filter(id)
#   within(filters_dropdown_panel) do
#     click_on id
#   end

#   wait_for_loaded
# end

# def filter_component(id)
#   find("[data-component='avo_filters/filter_component'][data-field-id='#{id.underscore}']")
# end

# def filter_pill(id)
#   filter_component(id).find(".pill")
# end

# def filter_panel(id)
#   filter_component(id).find("[data-toggle-target='panel']")
# end

# def fill_filter_value(id, with: "")
#   within(filter_panel(id)) do
#     find('input[data-control="value"]').set(with)
#   end
# end

# def apply_filter(id)
#   within(filter_panel(id)) do
#     click_on "Apply"
#   end

#   wait_for_loaded
# end

# def remove_filter(id)
#   within filter_pill(id) do
#     find('[data-action="avo-filters#removeFilter"]').click
#   end

#   wait_for_loaded
# end

# def filters_holder
#   page.find("turbo-frame#avo_filters_holder")
# end
