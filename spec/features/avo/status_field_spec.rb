require "rails_helper"

RSpec.describe "StatusField", type: :feature do
  context "index" do
    let(:url) { "/avo/resources/projects" }

    subject do
      visit url
      find("[data-resource-id='#{project.id}'] [data-field-id='status']")
    end

    describe "with any value" do
      let(:status) { "anything" }
      let!(:project) { create :project, users_required: 15, status: status }

      it { is_expected.to have_text status }
    end

    describe "with fail value" do
      let(:status) { "failed" }
      let!(:project) { create :project, users_required: 15, status: status }

      it {
        is_expected.to have_text status
        is_expected.to have_css ".text-red-700"
      }
    end

    describe "with wait value" do
      let(:status) { "waiting" }
      let!(:project) { create :project, users_required: 15, status: status }

      it {
        is_expected.to have_text status
        is_expected.to have_css ".spinner"
      }
    end

    describe "without value" do
      let!(:project) { create :project, users_required: 15, status: nil }

      it { is_expected.to have_text empty_dash }
    end
  end

  subject do
    visit url
    find_field_value_element("status")
  end

  context "show" do
    let(:url) { "/avo/resources/projects/#{project.id}" }

    describe "with any value" do
      let(:status) { "anything" }
      let!(:project) { create :project, users_required: 15, status: status }

      it { is_expected.to have_text status }
    end

    describe "with fail value" do
      let(:status) { "failed" }
      let!(:project) { create :project, users_required: 15, status: status }

      it {
        is_expected.to have_text status
        is_expected.to have_css ".text-red-700"
      }
    end

    describe "with wait value" do
      let(:status) { "waiting" }
      let!(:project) { create :project, users_required: 15, status: status }

      it {
        is_expected.to have_text status
        is_expected.to have_css ".spinner"
      }
    end

    describe "without value" do
      let!(:project) { create :project, users_required: 15, status: nil }

      it { is_expected.to have_text empty_dash }
    end
  end

  context "edit" do
    let(:url) { "/avo/resources/projects/#{project.id}/edit" }

    describe "with value" do
      let(:status) { "anything" }
      let(:fail_status) { "rejected" }
      let(:load_status) { "running" }
      let!(:project) { create :project, users_required: 15, status: status }

      it { is_expected.to have_xpath "//input[@id='project_status'][@value='#{status}']" }

      it "changes the status to fail value" do
        visit url
        expect(page).to have_xpath "//input[@id='project_status'][@value='#{status}']"

        fill_in "project_status", with: fail_status

        click_on "Save"

        expect(current_path).to eql "/avo/resources/projects/#{project.id}"
        expect(find_field_value_element("status")).to have_text fail_status
        expect(find_field_value_element("status")).to have_css ".text-red-700"
      end

      it "changes the status to load value" do
        visit url
        expect(page).to have_xpath "//input[@id='project_status'][@value='#{status}']"

        fill_in "project_status", with: load_status

        click_on "Save"

        expect(current_path).to eql "/avo/resources/projects/#{project.id}"
        expect(find_field_value_element("status")).to have_text load_status
        expect(find_field_value_element("status")).to have_css ".spinner"
      end

      it "clears the status" do
        visit url
        expect(page).to have_xpath "//input[@id='project_status'][@value='#{status}']"

        fill_in "project_status", with: nil

        click_on "Save"

        expect(current_path).to eql "/avo/resources/projects/#{project.id}"
        expect(find_field_value_element("status")).to have_text empty_dash
      end
    end

    describe "without value" do
      let(:status) { "anything" }
      let!(:project) { create :project, users_required: 15, status: nil }

      it { is_expected.to have_field "project_status", text: nil }

      it "sets the status" do
        visit url
        expect(page).to have_field "project_status", text: nil

        fill_in "project_status", with: status

        click_on "Save"

        expect(current_path).to eql "/avo/resources/projects/#{project.id}"
        expect(find_field_value_element("status")).to have_text status
      end
    end
  end
end
