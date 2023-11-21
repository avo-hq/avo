require "rails_helper"

RSpec.describe "Time field", type: :system do
  # We set the date so we can test out the DST too.
  let!(:course) { create :course, starting_at: Time.new(2022, 10, 2, 16, 30, 0, "UTC") }

  subject(:text_input) { find '[data-field-id="starting_at"] [data-controller="date-field"] input[type="text"]' }

  after do
    Avo::Resources::Course.restore_items_from_backup
  end

  describe "relative: false", tz: "Europe/Bucharest" do
    before do
      Avo::Resources::Course.with_temporary_items do
        field :starting_at, as: :time, relative: false, format: "HH:mm", picker_format: "H:i"
      end
    end

    it { reset_browser }

    context "index" do
      it "formats the time" do
        visit "/admin/resources/courses"

        expect(field_element_by_resource_id("starting_at", course.to_param).text).to eq "16:30"
      end
    end

    context "show" do
      it "formats the time" do
        visit "/admin/resources/courses/#{course.id}"

        expect(find_field_value_element("starting_at").text).to eq "16:30"
      end
    end

    context "edit" do
      it "sets the proper time without updating" do
        visit "/admin/resources/courses/#{course.id}/edit"

        expect(text_input.value).to eq "16:30"

        save

        expect(find_field_value_element("starting_at").text).to eq "16:30"
      end

      it "sets the proper time with updating" do
        visit "/admin/resources/courses/#{course.id}/edit"

        expect(text_input.value).to eq "16:30"

        open_picker
        set_picker_hour 17
        close_picker

        save

        expect(find_field_value_element("starting_at").text).to eq "17:30"
      end
    end
  end

  describe "relative: false", tz: "America/Los_Angeles" do
    before do
      Avo::Resources::Course.with_temporary_items do
        field :starting_at, as: :time, relative: false, format: "HH:mm", picker_format: "H:i"
      end
    end

    it { reset_browser }

    context "index" do
      it "formats the time" do
        visit "/admin/resources/courses"

        expect(field_element_by_resource_id("starting_at", course.to_param).text).to eq "16:30"
      end
    end

    context "show" do
      it "formats the time" do
        visit "/admin/resources/courses/#{course.id}"

        expect(find_field_value_element("starting_at").text).to eq "16:30"
      end
    end

    context "edit" do
      it "sets the proper time without updating" do
        visit "/admin/resources/courses/#{course.id}/edit"

        expect(text_input.value).to eq "16:30"

        save

        expect(find_field_value_element("starting_at").text).to eq "16:30"
      end

      it "sets the proper time with updating" do
        visit "/admin/resources/courses/#{course.id}/edit"

        expect(text_input.value).to eq "16:30"

        open_picker
        set_picker_hour 17
        close_picker

        save

        expect(find_field_value_element("starting_at").text).to eq "17:30"
      end
    end
  end

  describe "relative: true", tz: "Europe/Bucharest" do
    before do
      Avo::Resources::Course.with_temporary_items do
        field :starting_at, as: :time, relative: true, format: "HH:mm", picker_format: "H:i"
      end
    end

    it { reset_browser }

    context "index" do
      it "formats the time" do
        visit "/admin/resources/courses"

        expect(field_element_by_resource_id("starting_at", course.to_param).text).to eq "18:30"
      end
    end

    context "show" do
      it "formats the time" do
        visit "/admin/resources/courses/#{course.id}"

        expect(find_field_value_element("starting_at").text).to eq "18:30"
      end
    end

    context "edit" do
      it "sets the proper time without updating" do
        visit "/admin/resources/courses/#{course.id}/edit"

        expect(text_input.value).to eq "18:30"

        save

        expect(find_field_value_element("starting_at").text).to eq "18:30"
      end

      it "sets the proper time with updating" do
        visit "/admin/resources/courses/#{course.id}/edit"

        expect(text_input.value).to eq "18:30"

        open_picker
        set_picker_hour 17
        close_picker

        save

        expect(find_field_value_element("starting_at").text).to eq "17:30"
      end
    end
  end

  describe "relative: true", tz: "America/Los_Angeles" do
    before do
      Avo::Resources::Course.with_temporary_items do
        field :starting_at, as: :time, relative: true, format: "HH:mm", picker_format: "H:i"
      end
    end

    it { reset_browser }

    context "index" do
      it "formats the time" do
        visit "/admin/resources/courses"

        expect(field_element_by_resource_id("starting_at", course.to_param).text).to eq "08:30"
      end
    end

    context "show" do
      it "formats the time" do
        visit "/admin/resources/courses/#{course.id}"

        expect(find_field_value_element("starting_at").text).to eq "08:30"
      end
    end

    context "edit" do
      it "sets the proper time without updating" do
        visit "/admin/resources/courses/#{course.id}/edit"

        expect(text_input.value).to eq "08:30"

        save

        expect(find_field_value_element("starting_at").text).to eq "08:30"
      end

      it "sets the proper time with updating" do
        visit "/admin/resources/courses/#{course.id}/edit"

        expect(text_input.value).to eq "08:30"

        open_picker
        set_picker_hour 9
        close_picker

        save

        expect(find_field_value_element("starting_at").text).to eq "09:30"
      end
    end
  end
end
