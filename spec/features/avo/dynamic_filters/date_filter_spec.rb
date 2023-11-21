# EXTRACT:
# require "rails_helper"

# RSpec.feature "date dynamic filter", type: :feature do
#   let!(:slab_city) { create :city, name: "Slab city", population: nil, created_at: Date.new(1972) }
#   let!(:vatican) { create :city, name: "Vatican city", population: 450, created_at: Date.new(1929, 2, 11) }
#   let!(:barcelona) { create :city, name: "Barcelona", population: 1_600_000, created_at: Date.new(100) }
#   let!(:new_york) { create :city, name: "New York", population: 8_500_000, created_at: Date.new(1624) }

#   let(:filters_path) { "/admin/resources/cities" }

#   describe "is" do
#     it "applies the filter" do
#       visit_with_filters([["created_at", "is", "0100-01-01"]])

#       expect_record_not_present "Vatican city"
#       expect_record_present "Barcelona"
#       expect_record_not_present "New York"
#       expect(page).to have_text 'Created at is "0100-01-01"', normalize_ws: true
#     end
#   end

#   describe "is_not" do
#     it "applies the filter" do
#       visit_with_filters([["created_at", "is_not", "0100-01-01"]])

#       expect_record_present "Vatican city"
#       expect_record_not_present "Barcelona"
#       expect_record_present "New York"
#       expect(page).to have_text 'Created at is not "0100-01-01"', normalize_ws: true
#     end
#   end

#   describe "lte" do
#     it "applies the filter" do
#       visit_with_filters([["created_at", "lte", "0100-01-01"]])

#       expect_record_not_present "Vatican city"
#       expect_record_present "Barcelona"
#       expect_record_not_present "New York"
#       expect(page).to have_text 'Created at <= "0100-01-01"', normalize_ws: true
#     end
#   end

#   describe "gte" do
#     it "applies the figter" do
#       visit_with_filters([["created_at", "gte", "0100-01-01"]])

#       expect_record_present "Vatican city"
#       expect_record_present "Barcelona"
#       expect_record_present "New York"
#       expect(page).to have_text 'Created at >= "0100-01-01"', normalize_ws: true
#     end
#   end

#   describe "is_within" do
#     it "applies the figter" do
#       visit_with_filters([["created_at", "is_within", "0100-01-01 to 1625-01-01"]])

#       expect_record_not_present "Vatican city"
#       expect_record_present "Barcelona"
#       expect_record_present "New York"
#       expect_record_not_present "Slab city"
#       expect(page).to have_text 'Created at is within "0100-01-01 to 1625-01-01"', normalize_ws: true
#     end
#   end
# end
