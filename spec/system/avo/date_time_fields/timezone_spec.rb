require "rails_helper"

# Please use the reset_browser helpers before the first and after the last spec.
RSpec.describe "timezone", type: :system do
  let!(:project) { create :project, started_at: Time.new(2024, 3, 25, 8, 23, 0, "UTC") } # "March 25, 2024 08:23:00 UTC"

  subject(:text_input) { find '[data-field-id="started_at"] [data-controller="date-field"] input[type="text"]' }

  after do
    Avo::Resources::Project.restore_items_from_backup
  end

  describe "On Romania (EET) with CET timezone configured", tz: "Europe/Bucharest" do
    before do
      Avo::Resources::Project.with_temporary_items do
        field :started_at, as: :date_time, timezone: "CET", time_24hr: true, format: "MMMM dd, y HH:mm:ss z"
      end
    end

    it { reset_browser }

    context "index" do
      it "displays the date in CET tz" do
        visit "/admin/resources/projects"

        expect(index_field_value(id: :started_at, record_id: project.id)).to eq "March 25, 2024 09:23:00 CET"
      end
    end

    context "show" do
      it "displays the date in CET tz" do
        visit "/admin/resources/projects/#{project.id}"

        expect(show_field_value(id: :started_at)).to eq "March 25, 2024 09:23:00 CET"
      end
    end

    context "edit" do
      describe "when keeping the value" do
        it "saves the valid date" do
          visit "/admin/resources/projects/#{project.id}/edit"

          expect(text_input.value).to eq "2024-03-25 09:23:00"

          save

          expect(show_field_value(id: :started_at)).to eq "March 25, 2024 09:23:00 CET"
        end
      end

      describe "when changing the value" do
        it "saves the valid date" do
          visit "/admin/resources/projects/#{project.id}/edit"

          expect(text_input.value).to eq "2024-03-25 09:23:00"

          open_picker
          set_picker_minute 24
          set_picker_second 17

          close_picker

          save

          expect(show_field_value(id: :started_at)).to eq "March 25, 2024 09:24:17 CET"
        end
      end
    end
  end

  describe "On Romania (EET) with UTC timezone configured", tz: "Europe/Bucharest" do
    before do
      Avo::Resources::Project.with_temporary_items do
        field :started_at, as: :date_time, timezone: "UTC", time_24hr: true, format: "MMMM dd, y HH:mm:ss z"
      end
    end

    it { reset_browser }

    context "index" do
      it "displays the date in UTC tz" do
        visit "/admin/resources/projects"

        expect(index_field_value(id: :started_at, record_id: project.id)).to eq "March 25, 2024 08:23:00 UTC"
      end
    end

    context "show" do
      it "displays the date in UTC tz" do
        visit "/admin/resources/projects/#{project.id}"

        expect(show_field_value(id: :started_at)).to eq "March 25, 2024 08:23:00 UTC"
      end
    end

    context "edit" do
      describe "when keeping the value" do
        it "saves the valid date" do
          visit "/admin/resources/projects/#{project.id}/edit"

          expect(text_input.value).to eq "2024-03-25 08:23:00"

          save

          expect(show_field_value(id: :started_at)).to eq "March 25, 2024 08:23:00 UTC"
        end
      end

      describe "when changing the value" do
        it "saves the valid date" do
          visit "/admin/resources/projects/#{project.id}/edit"

          expect(text_input.value).to eq "2024-03-25 08:23:00"

          open_picker
          set_picker_minute 24
          set_picker_second 17

          close_picker

          save

          expect(show_field_value(id: :started_at)).to eq "March 25, 2024 08:24:17 UTC"
        end
      end
    end
  end
end
