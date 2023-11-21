require "rails_helper"

# Please use the reset_browser helpers before the first and after the last spec.
RSpec.describe "Date field", type: :system do
  let!(:project) { create :project, started_at: Time.new(2000, 1, 1, 6, 0, 0, "UTC") }

  subject(:text_input) { find '[data-field-id="started_at"] [data-controller="date-field"] input[type="text"]' }

  after do
    Avo::Resources::Project.restore_items_from_backup
  end

  describe "with relative: true", tz: "Europe/Bucharest" do
    before do
      Avo::Resources::Project.with_temporary_items do
        field :started_at, as: :date_time, relative: true, time_24hr: true, format: "MMMM dd, y HH:mm:ss z"
      end
    end

    it { reset_browser }

    context "index" do
      it "displays the date in a valid tz" do
        visit "/admin/resources/projects"

        expect(index_field_value(id: :started_at, record_id: project.id)).to eq "January 01, 2000 08:00:00 Europe/Bucharest"
      end
    end

    context "show" do
      it "displays the date in a valid tz" do
        visit "/admin/resources/projects/#{project.id}"

        expect(show_field_value(id: :started_at)).to eq "January 01, 2000 08:00:00 Europe/Bucharest"
      end
    end

    context "edit" do
      describe "when keeping the value" do
        it "saves the valid date" do
          visit "/admin/resources/projects/#{project.id}/edit"

          expect(text_input.value).to eq "2000-01-01 08:00:00"

          save

          expect(show_field_value(id: :started_at)).to eq "January 01, 2000 08:00:00 Europe/Bucharest"
        end
      end

      describe "when changing the value" do
        it "saves the valid date" do
          visit "/admin/resources/projects/#{project.id}/edit"

          expect(text_input.value).to eq "2000-01-01 08:00:00"

          open_picker
          set_picker_day "January 2, 2000"
          set_picker_hour 17
          set_picker_minute 17
          set_picker_second 17

          close_picker

          save

          expect(show_field_value(id: :started_at)).to eq "January 02, 2000 17:17:17 Europe/Bucharest"
        end
      end
    end
  end

  describe "with relative: true", tz: "America/Los_Angeles" do
    before do
      Avo::Resources::Project.with_temporary_items do
        field :started_at, as: :date_time, relative: true, time_24hr: true, format: "MMMM dd, y HH:mm:ss z"
      end
    end

    # Unfortunately I couldn't find a better way to run this.
    # It seems that in before/after hooks the session does not get reset
    it { reset_browser }

    context "index" do
      it "displays the date in a valid tz" do
        visit "/admin/resources/projects"

        expect(index_field_value(id: :started_at, record_id: project.id)).to eq "December 31, 1999 22:00:00 America/Los_Angeles"
      end
    end

    context "show" do
      it "displays the date in a valid tz" do
        visit "/admin/resources/projects/#{project.id}"

        expect(show_field_value(id: :started_at)).to eq "December 31, 1999 22:00:00 America/Los_Angeles"
      end
    end

    context "edit" do
      describe "when keeping the value" do
        it "saves the valid date" do
          visit "/admin/resources/projects/#{project.id}/edit"

          expect(text_input.value).to eq "1999-12-31 22:00:00"

          save

          expect(show_field_value(id: :started_at)).to eq "December 31, 1999 22:00:00 America/Los_Angeles"
        end
      end

      describe "when changing the value" do
        it "saves the valid date" do
          visit "/admin/resources/projects/#{project.id}/edit"

          expect(text_input.value).to eq "1999-12-31 22:00:00"

          open_picker
          set_picker_day "January 2, 2000"
          set_picker_hour 17
          set_picker_minute 17
          set_picker_second 17

          close_picker

          save

          expect(show_field_value(id: :started_at)).to eq "January 02, 2000 17:17:17 America/Los_Angeles"
        end
      end
    end
  end

  describe "with relative: false", tz: "Europe/Bucharest" do
    before do
      Avo::Resources::Project.with_temporary_items do
        field :started_at, as: :date_time, relative: false, time_24hr: true, format: "MMMM dd, y HH:mm:ss z"
      end
    end

    it { reset_browser }

    context "index" do
      it "displays the date in a valid tz" do
        visit "/admin/resources/projects"

        expect(index_field_value(id: :started_at, record_id: project.id)).to eq "January 01, 2000 06:00:00 UTC"
      end
    end

    context "show" do
      it "displays the date in a valid tz" do
        visit "/admin/resources/projects/#{project.id}"

        expect(show_field_value(id: :started_at)).to eq "January 01, 2000 06:00:00 UTC"
      end
    end

    context "edit" do
      describe "when keeping the value" do
        it "saves the valid date" do
          visit "/admin/resources/projects/#{project.id}/edit"

          expect(text_input.value).to eq "2000-01-01 06:00:00"

          save

          expect(show_field_value(id: :started_at)).to eq "January 01, 2000 06:00:00 UTC"
        end
      end

      describe "when changing the value" do
        it "saves the valid date" do
          visit "/admin/resources/projects/#{project.id}/edit"

          expect(text_input.value).to eq "2000-01-01 06:00:00"

          open_picker
          set_picker_day "January 2, 2000"
          set_picker_hour 17
          set_picker_minute 17
          set_picker_second 17

          close_picker
          save

          expect(show_field_value(id: :started_at)).to eq "January 02, 2000 17:17:17 UTC"
        end
      end
    end
  end

  describe "with relative: false", tz: "America/Los_Angeles" do
    before do
      Avo::Resources::Project.with_temporary_items do
        field :started_at, as: :date_time, relative: false, time_24hr: true, format: "MMMM dd, y HH:mm:ss z"
      end
    end

    it { reset_browser }

    context "index" do
      it "displays the date in a valid tz" do
        visit "/admin/resources/projects"

        expect(index_field_value(id: :started_at, record_id: project.id)).to eq "January 01, 2000 06:00:00 UTC"
      end
    end

    context "show" do
      it "displays the date in a valid tz" do
        visit "/admin/resources/projects/#{project.id}"

        expect(show_field_value(id: :started_at)).to eq "January 01, 2000 06:00:00 UTC"
      end
    end

    context "edit" do
      describe "when keeping the value" do
        it "saves the valid date" do
          visit "/admin/resources/projects/#{project.id}/edit"

          expect(text_input.value).to eq "2000-01-01 06:00:00"

          save

          expect(show_field_value(id: :started_at)).to eq "January 01, 2000 06:00:00 UTC"
        end
      end

      describe "when changing the value" do
        it "saves the valid date" do
          visit "/admin/resources/projects/#{project.id}/edit"

          expect(text_input.value).to eq "2000-01-01 06:00:00"

          open_picker
          set_picker_day "January 2, 2000"
          set_picker_hour 17
          set_picker_minute 17
          set_picker_second 17

          close_picker
          save

          expect(show_field_value(id: :started_at)).to eq "January 02, 2000 17:17:17 UTC"
        end
      end
    end
  end
end
