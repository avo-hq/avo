# EXTRACT:
# require "rails_helper"

# RSpec.feature "Number dynamic filter", type: :feature do
#   let!(:slab_city) { create :city, name: "Slab city", population: nil }
#   let!(:vatican) { create :city, name: "Vatican city", population: 450 }
#   let!(:barcelona) { create :city, name: "Barcelona", population: 1_600_000 }
#   let!(:new_york) { create :city, name: "New York", population: 8_500_000 }

#   let(:filters_path) { "/admin/resources/cities" }

#   describe "is" do
#     it "applies the filter" do
#       visit_with_filters([["population", "is", "450"]])

#       expect_record_present "Vatican city"
#       expect_record_not_present "Barcelona"
#       expect_record_not_present "New York"
#       expect(page).to have_text 'Population is "450"', normalize_ws: true
#     end
#   end

#   describe "is_not" do
#     it "applies the filter" do
#       visit_with_filters([["population", "is_not", "450"]])

#       expect_record_not_present "Vatican city"
#       expect_record_present "Barcelona"
#       expect_record_present "New York"
#       expect(page).to have_text 'Population is not "450"', normalize_ws: true
#     end
#   end

#   describe "gt" do
#     it "applies the filter" do
#       visit_with_filters([["population", "gt", "450"]])

#       expect_record_not_present "Vatican city"
#       expect_record_present "Barcelona"
#       expect_record_present "New York"
#       expect(page).to have_text 'Population > "450"', normalize_ws: true
#     end
#   end

#   describe "gte" do
#     it "applies the filter" do
#       visit_with_filters([["population", "gte", "450"]])

#       expect_record_present "Vatican city"
#       expect_record_present "Barcelona"
#       expect_record_present "New York"
#       expect(page).to have_text 'Population >= "450"', normalize_ws: true
#     end
#   end

#   describe "lt" do
#     it "applies the filter" do
#       visit_with_filters([["population", "lt", "1600000"]])

#       expect_record_present "Vatican city"
#       expect_record_not_present "Barcelona"
#       expect_record_not_present "New York"
#       expect(page).to have_text 'Population < "1600000"', normalize_ws: true
#     end
#   end

#   describe "lte" do
#     it "applies the filter" do
#       visit_with_filters([["population", "lte", "1600000"]])

#       expect_record_present "Vatican city"
#       expect_record_present "Barcelona"
#       expect_record_not_present "New York"
#       expect(page).to have_text 'Population <= "1600000"', normalize_ws: true
#     end
#   end

#   describe "is_present" do
#     it "applies the filter" do
#       visit_with_filters([["population", "is_present", "1"]])

#       expect_missing_component("avo/index/resource_table_component")
#       expect(page).to have_text "Population present", normalize_ws: true
#     end
#   end

#   describe "is_blank" do
#     it "applies the filter" do
#       visit_with_filters([["population", "is_blank", ""]])

#       expect_record_present "Slab city"
#       expect_record_not_present "Vatican city"
#       expect_record_not_present "Barcelona"
#       expect_record_not_present "New York"
#       expect(page).to have_text "Population blank", normalize_ws: true
#     end
#   end
# end
