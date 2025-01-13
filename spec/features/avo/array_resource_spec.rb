require "rails_helper"

RSpec.feature "ArrayResource", type: :feature do
  describe "from index to show" do
    it "render the movies index using the def records resource method and navigate to show" do
      visit path = avo.resources_movies_path(per_page: 12)

      expect(find("table thead").text).to eq "Select all\nId\nName\nRelease date\nFun fact"
      expect(page).to have_text "The Shawshank Redemption"
      expect(page).to have_text "The iconic cat in the opening scene was a stray..."

      first("a[href=\"#{path}&page=2\"]").click
      expect(find("table thead").text).to eq "Select all\nId\nName\nRelease date"

      expect(page).to have_text "The Lord of the Rings: The Fellowship of the Ring"

      first("a[href=\"#{path}&page=3\"]").click

      first('a[href="/admin/resources/movies/28"]').click

      within("div.resource-sidebar-component") do
        fun_fact_text = find('div[data-field-id="fun_fact"] [data-slot="value"]').text
        expect(fun_fact_text).to eq "Ryan Gosling learned to play the piano for his role, mastering several songs within three months."
      end
    end

    it "render the attendees index using the def records resource method and navigate to show" do
      visit avo.resources_attendees_path

      expect(find("table thead").text).to eq "Select all\nId\nName"
      expect(page).to have_text User.first.name

      first("a[href=\"#{avo.resources_attendee_path User.first}\"]").click

      name = find('div[data-field-id="name"] [data-slot="value"]').text
      expect(name).to eq User.first.name
    end
  end

  describe "from has_many association to show" do
    it "using the field block" do

    end
  end
end
