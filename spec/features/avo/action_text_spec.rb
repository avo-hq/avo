require "rails_helper"

RSpec.feature "ActionTexts", type: :feature do
  let(:city) { create :city, description: "<script>alert('something evil')</script><strong>bold text!!!</strong>" }

  describe "show" do
    it "loads the editor and content" do
      visit "/admin/resources/cities/#{city.id}"

      expect(page).to have_selector "strong", text: "bold text!!!"
      expect(page).to have_text "alert('something evil')"
      expect(page).not_to have_selector "script", text: "alert('something evil')"
    end
  end

  describe "edit" do
    it "loads the editor and content" do
      visit "/admin/resources/cities/#{city.id}/edit"

      expect(page).to have_selector "strong", text: "bold text!!!"
      expect(page).to have_text "alert('something evil')"
      expect(page).not_to have_selector "script", text: "alert('something evil')"
    end
  end
end
