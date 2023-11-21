# EXTRACT:
# require "rails_helper"

# RSpec.feature "boolean dynamic filter", type: :feature do
#   let!(:slab_city) { create :city, name: "Slab city", population: nil, is_capital: false }
#   let!(:vatican) { create :city, name: "Vatican city", population: 450, is_capital: false }
#   let!(:barcelona) { create :city, name: "Barcelona", population: 1_600_000, is_capital: true }
#   let!(:new_york) { create :city, name: "New York", population: 8_500_000, is_capital: false }

#   let(:filters_path) { "/admin/resources/cities" }

#   describe "is_true" do
#     it "applies the filter" do
#       visit_with_filters([["is_capital", "is_true", ""]])

#       expect_record_not_present "Vatican city"
#       expect_record_present "Barcelona"
#       expect_record_not_present "New York"
#       expect(page).to have_text "Is capital true", normalize_ws: true
#     end
#   end

#   describe "is_false" do
#     it "applies the filter" do
#       visit_with_filters([["is_capital", "is_false", ""]])

#       expect_record_present "Vatican city"
#       expect_record_not_present "Barcelona"
#       expect_record_present "New York"
#       expect(page).to have_text "Is capital false", normalize_ws: true
#     end
#   end
# end
