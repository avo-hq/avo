require "rails_helper"

RSpec.describe "Date field", type: :system do
  let!(:user) { create :user, birthday: Date.new(1988, 2, 10) }

  subject(:text_input) { find '[data-field-id="birthday"] [data-controller="date-field"] input[type="text"]' }

  describe "in a western (negative) Timezone", tz: "Europe/Berlin" do
    it { reset_browser }

    context "index" do
      it "formats the date" do
        visit "/admin/resources/users"

        expect(field_element_by_resource_id("birthday", user.to_param).text).to eq "Wednesday, 10 February 1988"
      end
    end

    context "show" do
      it "formats the date" do
        visit "/admin/resources/users/#{user.id}"

        expect(find_field_value_element("birthday").text).to eq "Wednesday, 10 February 1988"
      end
    end

    context "edit" do
      it "sets the proper date without updates" do
        visit "/admin/resources/users/#{user.id}/edit"

        scroll_to find_all('[data-target="tab-group"]').first
        wait_for_turbo_frame_id "avo-tabgroup-2-avo-tab-birthday"

        expect(text_input.value).to eq "February 10th 1988"

        save

        expect(find_field_value_element("birthday").text).to eq "Wednesday, 10 February 1988"
      end

      it "sets the proper date with updates" do
        visit "/admin/resources/users/#{user.id}/edit"

        scroll_to find_all('[data-target="tab-group"]').first
        wait_for_turbo_frame_id "avo-tabgroup-2-avo-tab-birthday"

        expect(text_input.value).to eq "February 10th 1988"

        open_picker
        set_picker_day "February 9, 1988"

        save

        expect(find_field_value_element("birthday").text).to eq "Tuesday, 9 February 1988"
      end
    end
  end

  describe "in an eastern (positive) Timezone", tz: "Europe/Bucharest" do
    it { reset_browser }

    context "index" do
      it "formats the date" do
        visit "/admin/resources/users"

        expect(field_element_by_resource_id("birthday", user.to_param).text).to eq "Wednesday, 10 February 1988"
      end
    end

    context "show" do
      it "formats the date" do
        visit "/admin/resources/users/#{user.id}"

        expect(find_field_value_element("birthday").text).to eq "Wednesday, 10 February 1988"
      end
    end

    context "edit" do
      it "sets the proper date without" do
        visit "/admin/resources/users/#{user.id}/edit"

        expect(find('[data-field-id="birthday"] [data-controller="date-field"] input[type="hidden"]', visible: false).value).to eq "1988-02-10"
        expect(find('[data-field-id="birthday"] [data-controller="date-field"] input[type="text"]').value).to eq "February 10th 1988"

        wait_for_turbo_frame_id "avo-tabgroup-2-avo-tab-birthday"

        save
        sleep 0.1

        expect(find_field_value_element("birthday").text).to eq "Wednesday, 10 February 1988"
      end

      it "sets the proper date with updates" do
        visit "/admin/resources/users/#{user.id}/edit"

        scroll_to find_all('[data-target="tab-group"]').first
        wait_for_turbo_frame_id "avo-tabgroup-2-avo-tab-birthday"

        expect(text_input.value).to eq "February 10th 1988"

        open_picker
        set_picker_day "February 9, 1988"

        save
        sleep 0.1

        expect(find_field_value_element("birthday").text).to eq "Tuesday, 9 February 1988"
      end
    end
  end
end
