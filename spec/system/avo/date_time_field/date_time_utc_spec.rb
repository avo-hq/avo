require "rails_helper"

RSpec.describe "Date field", type: :system do
  let!(:comment) { create :comment, posted_at: Time.new(1988, 2, 10, 16, 22, 00, "UTC") }

  describe "on UTC", tz: "UTC" do
    context "index" do
      it "displays the time" do
        visit "/admin/resources/comments"

        expect(field_element_by_resource_id("posted_at", comment.id).text).to eq "10 February 1988 at 16:22 GMT"
      end
    end

    context "show" do
      it "displays the time" do
        visit "/admin/resources/comments/#{comment.id}"

        expect(find_field_value_element("posted_at").text).to eq "10 February 1988 at 16:22 GMT"
      end
    end

    context "edit" do
      it "keeps the same value on save" do
        visit "/admin/resources/comments/#{comment.id}/edit"

        expect(hidden_input.value).to eq "1988-02-10 16:22:00"
        expect(text_input.value).to eq "1988-02-10 16:22:00"

        click_on "Save"

        expect(field_element_by_resource_id("posted_at", comment.id).text).to eq "10 February 1988 at 16:22 GMT"
      end

      it "keeps the right value on update and save" do
        visit "/admin/resources/comments/#{comment.id}/edit"

        # Open the picker.
        text_input.click
        find('.flatpickr-day[aria-label="February 11, 1988"]').click
        find('.flatpickr-hour').set(17)
        find('.flatpickr-minute').set(17)
        find('.flatpickr-second').set(17)

        # Close the picker.
        find_field_value_element("body").click
        # Wait for the picker to close.
        sleep 0.3

        click_on "Save"

        expect(field_element_by_resource_id("posted_at", comment.id).text).to eq "11 February 1988 at 17:17 GMT"
      end
    end
  end
end

def text_input
  find '[data-field-id="posted_at"] [data-controller="date-field"] input[type="text"]'
end

def hidden_input
  find '[data-field-id="posted_at"] [data-controller="date-field"] input[type="hidden"]', visible: false
end
