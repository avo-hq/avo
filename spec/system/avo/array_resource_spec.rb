require "rails_helper"

RSpec.feature "ArrayResource", type: :system do
  describe "from has_many association to show" do
    let!(:event) { create :event }
    let!(:course) { create :course }
    let(:users) { create_list :user, 6 }

    it "using the field block" do
      visit avo.resources_event_path(event)

      wait_for_loaded

      expect(strip_html(find("table thead").text)).to eq "Select all ID Name Role Organization"

      expect(page).to have_text("Attendees from field")
      expect(page).to have_text("John Doe")
      expect(page).to have_text("Ethan Williams")

      all('button[data-action="alert#close"]').each(&:click)

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

      scroll_to find('turbo-frame[id="array_field_show_attendees"]')

      wait_for_turbo_frame_id("array_field_show_attendees")

      expect(page).to have_text("First 6 users")

      expect(strip_html(find("table thead").text)).to eq "Select all ID Name"

      User.first(6).each do |user|
        expect(page).to have_text(user.name)
      end

      all('a[data-control="show"]').last.click
      expect(page).to have_text("#{User.first(6).last.name} rendered as array resource")
    end

    it "can access query on actions" do
      visit avo.resources_movies_path

      check_select_all
      click_on "Select all matching"

      movies_count = 50

      open_panel_action(action_name: "Test query access ")

      expect(page).to have_text("message #{movies_count} selected")
      expect(page).to have_field("fields_selected", with: "#{movies_count} selected def fields")
      expect(page).to have_text("cancel_button_label #{movies_count} selected")
      expect(page).to have_text("confirm_button_label #{movies_count} selected")
      expect(page).to have_text("Test query access #{movies_count}")

      run_action

      expect(page).to have_text("succeed #{movies_count} selected")
    end
  end
end
