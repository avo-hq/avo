require "rails_helper"

# Even though we have the date time field tested in projects, this covers a different resource.
RSpec.describe "Date field on eastern zone", type: :system do
  let!(:comment) { create :comment, posted_at: Time.new(1988, 2, 10, 16, 22, 0, "UTC") }

  subject(:text_input) { find '[data-field-id="posted_at"] [data-controller="date-field"] input[type="text"]' }

  describe "in an eastern (positive) Timezone", tz: "Europe/Bucharest" do
    it { reset_browser }

    context "index" do
      it "displays the time" do
        visit "/admin/resources/comments"

        expect(field_element_by_resource_id("posted_at", comment.id).text).to eq "Wednesday, 10 February 1988, 16:22 UTC"
      end
    end

    context "show" do
      it "displays the time" do
        visit "/admin/resources/comments/#{comment.id}"

        expect(find_field_value_element("posted_at").text).to eq "Wednesday, 10 February 1988, 16:22 UTC"
      end
    end

    context "edit" do
      it "keeps the same value on save" do
        visit "/admin/resources/comments/#{comment.id}/edit"

        expect(text_input.value).to eq "1988-02-10 16:22:00"

        save

        expect(field_element_by_resource_id("posted_at", comment.id).text).to eq "Wednesday, 10 February 1988, 16:22 UTC"
      end

      it "keeps the right value on update and save" do
        visit "/admin/resources/comments/#{comment.id}/edit"

        open_picker
        set_picker_day "February 11, 1988"
        set_picker_hour 19
        set_picker_minute 17
        set_picker_minute 17
        close_picker
        save

        expect(field_element_by_resource_id("posted_at", comment.id).text).to eq "Thursday, 11 February 1988, 19:17 UTC"
      end
    end
  end
end
