require "rails_helper"

RSpec.describe "Time field", type: :system do
  let!(:course) { create :course, starting_at: Time.new(2022, 10, 18, 16, 30, 0) }

  describe "time field" do
    context "index" do
      it "formats the time" do
        visit "/admin/resources/courses"
        expect(field_element_by_resource_id("starting_at", course.id).text).to eq "16:30"
      end
    end

    context "show" do
      it "formats the time" do
        visit "/admin/resources/courses/#{course.id}"

        expect(find_field_value_element("starting_at").text).to eq "16:30"
      end
    end

    context "edit" do
      it "keeps the proper time" do
        visit "/admin/resources/courses/#{course.id}/edit"

        expect(find('[data-field-id="starting_at"] [data-controller="date-field"] input[name="course[starting_at]"]', visible: false).value).to eq "16:30:00"
        expect(find('[data-field-id="starting_at"] [data-controller="date-field"] input[type="text"]').value).to eq "16:30"

        click_on "Save"
        wait_for_loaded

        expect(find_field_value_element("starting_at").text).to eq "16:30"
      end

      it "sets the proper time" do
        visit "/admin/resources/courses/#{course.id}/edit"

        expect(find('[data-field-id="starting_at"] [data-controller="date-field"] input[name="course[starting_at]"]', visible: false).value).to eq "16:30:00"
        expect(find('[data-field-id="starting_at"] [data-controller="date-field"] input[type="text"]').value).to eq "16:30"

        find('[data-field-id="starting_at"] [data-controller="date-field"] input[type="text"]').click
        sleep 0.1
        find(".numInput.flatpickr-hour").set "17"
        find('[data-target="title"]').click
        sleep 0.3

        click_on "Save"
        wait_for_loaded

        expect(find_field_value_element("starting_at").text).to eq "17:30"
      end
    end
  end
end
