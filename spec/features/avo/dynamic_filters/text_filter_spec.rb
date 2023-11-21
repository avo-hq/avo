# EXTRACT:
# require "rails_helper"

# RSpec.feature "Text dynamic filter", type: :feature do
#   let!(:apple) { create :team, name: "Apple", team_members: [admin] }
#   let!(:tesla) { create :team, name: "Tesla", team_members: [admin] }
#   let!(:amazon) { create :team, name: "Amazon", team_members: [admin] }
#   let!(:netflix) { create :team, name: "Netflix", team_members: [admin] }

#   let(:filters_path) { "/admin/resources/teams" }

#   describe "contains" do
#     it "applies the filter" do
#       visit_with_filters([["name", "contains", "a"]])

#       expect_record_present "Apple"
#       expect_record_not_present "Netflix"
#       expect(page).to have_text 'Name contains "a"', normalize_ws: true
#     end
#   end

#   describe "does_not_contain" do
#     it "applies the filter" do
#       visit_with_filters([["name", "does_not_contain", "flix"]])

#       expect_record_present "Apple"
#       expect_record_not_present "Netflix"
#       expect(page).to have_text 'Name does not contain "flix"', normalize_ws: true
#     end
#   end

#   describe "is" do
#     it "applies the filter" do
#       visit_with_filters([["name", "is", "Amazon"]])

#       expect_record_present "Amazon"
#       expect_record_not_present "Apple"
#       expect_record_not_present "Netflix"
#       expect(page).to have_text 'Name is "Amazon"', normalize_ws: true
#     end
#   end

#   describe "is_not" do
#     it "applies the filter" do
#       visit_with_filters([["name", "is_not", "Amazon"]])

#       expect(find_component("avo/index/resource_table_component")).not_to have_text "Amazon"
#       expect_record_present "Apple"
#       expect_record_present "Netflix"
#       expect(page).to have_text 'Name is not "Amazon"', normalize_ws: true
#     end
#   end

#   describe "starts_with" do
#     it "applies the filter" do
#       visit_with_filters([["name", "starts_with", "t"]])

#       expect_record_not_present "Apple"
#       expect_record_present "Tesla"
#       expect_record_not_present "Amazon"
#       expect_record_not_present "Netflix"
#       expect(page).to have_text 'Name starts with "t"', normalize_ws: true
#     end
#   end

#   describe "ends_with" do
#     it "applies the filter" do
#       visit_with_filters([["name", "ends_with", "x"]])

#       expect_record_not_present "Apple"
#       expect_record_not_present "Tesla"
#       expect_record_not_present "Amazon"
#       expect_record_present "Netflix"
#       expect(page).to have_text 'Name ends with "x"', normalize_ws: true
#     end
#   end

#   describe "is_present" do
#     it "applies the filter" do
#       visit_with_filters([["name", "is_present", ""]])

#       expect_record_present "Apple"
#       expect_record_present "Tesla"
#       expect_record_present "Amazon"
#       expect_record_present "Netflix"
#       expect(page).to have_text "Name present", normalize_ws: true
#     end
#   end

#   describe "is_blank" do
#     it "applies the filter" do
#       visit_with_filters([["name", "is_blank", ""]])

#       expect_missing_component("avo/index/resource_table_component")
#       expect(page).to have_text "Name blank", normalize_ws: true
#     end
#   end
# end

