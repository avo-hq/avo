# EXTRACT:
# require "rails_helper"

# RSpec.feature "select dynamic filter", type: :feature do
#   let!(:airpods) { create :project, name: "AirPods", stage: :Idea }
#   let!(:iphone) { create :project, name: "iPhone", stage: :Cancelled }

#   let(:filters_path) { "/admin/resources/projects" }

#   describe "is" do
#     it "applies the filter" do
#       visit_with_filters([["stage", "is", "idea"]])

#       expect_record_present "AirPods"
#       expect_record_not_present "iPhone"
#       expect(page).to have_text 'Stage is "Idea"', normalize_ws: true
#     end
#   end

#   describe "is_not" do
#     it "applies the filter" do
#       visit_with_filters([["stage", "is_not", "idea"]])

#       expect_record_not_present "AirPods"
#       expect_record_present "iPhone"
#       expect(page).to have_text 'Stage is not "Idea"', normalize_ws: true
#     end
#   end

#   describe "is_present" do
#     it "applies the filter" do
#       visit_with_filters([["stage", "is_present", ""]])

#       expect_record_present "AirPods"
#       expect_record_present "iPhone"
#       expect(page).to have_text "Stage present", normalize_ws: true
#     end
#   end

#   describe "is_blank" do
#     it "applies the filter" do
#       visit_with_filters([["stage", "is_blank", ""]])

#       expect_missing_component("avo/index/resource_table_component")
#       expect(page).to have_text "Stage blank", normalize_ws: true
#     end
#   end
# end
