require "rails_helper"

RSpec.describe "StatusField", type: :feature do
  context "index" do
    let(:url) { "/admin/resources/projects" }

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
        is_expected.to have_css ".text-red-600"
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
    let(:url) { "/admin/resources/projects/#{project.id}" }

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
        is_expected.to have_css ".text-red-600"
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
    let(:url) { "/admin/resources/projects/#{project.id}/edit" }

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

        expect(current_path).to eql "/admin/resources/projects/#{project.id}"
        expect(find_field_value_element("status")).to have_text fail_status
        expect(find_field_value_element("status")).to have_css ".text-red-600"
      end

      it "changes the status to load value" do
        visit url
        expect(page).to have_xpath "//input[@id='project_status'][@value='#{status}']"

        fill_in "project_status", with: load_status

        click_on "Save"

        expect(current_path).to eql "/admin/resources/projects/#{project.id}"
        expect(find_field_value_element("status")).to have_text load_status
        expect(find_field_value_element("status")).to have_css ".spinner"
      end

      it "clears the status" do
        visit url
        expect(page).to have_xpath "//input[@id='project_status'][@value='#{status}']"

        fill_in "project_status", with: nil

        click_on "Save"

        expect(current_path).to eql "/admin/resources/projects/#{project.id}"
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

        expect(current_path).to eql "/admin/resources/projects/#{project.id}"
        expect(find_field_value_element("status")).to have_text status
      end
    end
  end

  describe "without value" do
    let!(:project) { create :project, status: "" }

    context "index" do
      it "displays the empty state status" do
        visit "/admin/resources/projects"

        expect(find_field_element("status")).to have_text empty_dash
      end
    end

    context "show" do
      it "displays the projects status" do
        visit "/admin/resources/projects/#{project.id}"

        expect(find_field_value_element("status")).to have_text empty_dash
      end
    end

    context "edit" do
      it "has the projects status pre-filled" do
        visit "/admin/resources/projects/#{project.id}/edit"

        expect(find_field("project_status").value).to eq ""
      end
    end
  end

  describe "with waiting value" do
    let!(:project) { create :project, status: "waiting" }

    context "index" do
      it "displays the empty state status" do
        visit "/admin/resources/projects"

        expect(find_field_element("status")).to have_text "waiting"
        expect(find_field_element("status")).to have_css ".spinner"
      end

      it "displays the projects status" do
        visit "/admin/resources/projects"

        expect(find_field_element("status")).to have_text "waiting"
        expect(find_field_element("status")).to have_css ".spinner"
      end
    end

    context "show" do
      it "displays the projects status" do
        visit "/admin/resources/projects/#{project.id}"

        expect(find_field_element("status")).to have_text "waiting"
        expect(find_field_element("status")).to have_css ".spinner"
      end
    end

    context "edit" do
      it "has the projects status pre-filled" do
        visit "/admin/resources/projects/#{project.id}/edit"

        expect(find_field("project_status").value).to eq "waiting"
      end

      it "changes the projects status to normal" do
        visit "/admin/resources/projects/#{project.id}/edit"

        fill_in "project_status", with: "normal"

        click_on "Save"
        wait_for_loaded

        expect(current_path).to eql "/admin/resources/projects/#{project.id}"

        expect(find_field_element("status")).to have_text "normal"
        expect(find_field_element("status")).not_to have_css ".text-red-600"
        expect(find_field_element("status")).not_to have_css ".spinner"
      end

      it "changes the projects status to failed" do
        visit "/admin/resources/projects/#{project.id}/edit"

        fill_in "project_status", with: "failed"

        click_on "Save"
        wait_for_loaded

        expect(current_path).to eql "/admin/resources/projects/#{project.id}"
        expect(find_field_value_element("status")).to have_text "failed"
        expect(find_field_element("status")).to have_css ".text-red-600"
        expect(find_field_element("status")).not_to have_css ".spinner"
      end

      it "changes the projects status to waiting" do
        visit "/admin/resources/projects/#{project.id}/edit"

        fill_in "project_status", with: "waiting"

        click_on "Save"
        wait_for_loaded

        expect(current_path).to eql "/admin/resources/projects/#{project.id}"

        expect(find_field_element("status")).to have_text "waiting"
        expect(find_field_element("status")).to have_css ".spinner"
        expect(find_field_element("status")).not_to have_css ".text-red-600"
      end
    end
  end

  describe "with 'Hold On' loading_when value" do
    let!(:project) { create :project, status: "Hold On" }

    context "index" do
      it "displays the projects status" do
        visit "/admin/resources/projects"

        expect(find_field_element("status")).to have_text "Hold On"
        expect(find_field_element("status")).to have_css ".spinner"
      end
    end
  end

  describe "with 'user_reject' failed_when value" do
    let!(:project) { create :project, status: "user_reject" }

    context "index" do
      it "displays the projects status" do
        visit "/admin/resources/projects"

        expect(find_field_element("status")).to have_text "user_reject"
        expect(find_field_element("status")).to have_css ".text-red-600"
      end
    end
  end
end
