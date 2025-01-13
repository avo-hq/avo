require "rails_helper"

RSpec.feature "ArrayResource", type: :system do
  describe "from has_many association to show" do
    let!(:event) { create :event }
    let!(:course) { create :course }
    let(:users) { create_list :user, 6 }

    it "using the field block" do
      visit avo.resources_event_path(event)

      wait_for_loaded

      expect(find("table thead").text).to eq "Select all\n\t\nID\n\t\nNAME\n\t\nROLE\n\t\nORGANIZATION"

      expect(page).to have_text("Attendees from field")
      expect(page).to have_text("John Doe")
      expect(page).to have_text("Ethan Williams")

      within("nav.pagy.nav") do
        click_link("2")
      end

      expect(page).to have_text("Benjamin Green")
      expect(page).to have_text("Sophia Martinez")

      first('a[data-control="show"]').click
      expect(page).to have_text("Sophia Martinez rendered as array resource")

      expect(page).to have_text("Sophia Martinez")
      expect(page).to have_text("Marketing Strategist")
      expect(page).to have_text("Brandify")
    end

    it "using the record method" do
      visit avo.resources_course_path(course)

      Capybara.using_wait_time(Capybara.default_max_wait_time) do
        expect(page).to have_text("First 6 users")
      end

      expect(find("table thead").text).to eq "Select all\n\t\nID\n\t\nNAME"

      User.first(6).each do |user|
        expect(page).to have_text(user.name)
      end

      all('a[data-control="show"]').last.click
      expect(page).to have_text("#{User.first(6).last.name} rendered as array resource")
    end
  end
end
