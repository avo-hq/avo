require "rails_helper"

RSpec.describe "number", type: :feature do
  context "index" do
    let(:url) { "/admin/resources/projects" }

    subject do
      visit url
      find("[data-resource-id='#{project.id}'] [data-field-id='users_required']")
    end

    describe "with value" do
      let(:users_required) { 10 }
      let!(:project) { create :project, users_required: users_required }

      it { is_expected.to have_text users_required }
    end
  end

  subject do
    visit url
    find_field_element("users_required")
  end

  context "show" do
    let(:url) { "/admin/resources/projects/#{project.id}" }

    describe "with value" do
      let(:users_required) { 50 }
      let!(:project) { create :project, users_required: users_required }

      it { is_expected.to have_text users_required }
    end
  end

  context "edit" do
    let(:url) { "/admin/resources/projects/#{project.id}/edit" }

    describe "with value" do
      let(:users_required) { 50 }
      let(:new_users_required) { 100 }
      let(:under_min_users_required) { 9 }
      let(:over_max_users_required) { 1000001 }
      let!(:project) { create :project, users_required: users_required }

      it { is_expected.to have_xpath "//input[@id='project_users_required'][@type='number'][@placeholder='Users required'][@min='10.0'][@max='1000000.0'][@step='1.0'][@value='#{users_required}']" }

      it "changes the users_required to correct value" do
        is_expected.to have_xpath "//input[@id='project_users_required'][@type='number'][@placeholder='Users required'][@min='10.0'][@max='1000000.0'][@step='1.0'][@value='#{users_required}']"

        fill_in "project_users_required", with: new_users_required

        click_on "Save"

        expect(current_path).to eql "/admin/resources/projects/#{project.id}"
        is_expected.to have_text new_users_required
      end

      it "changes the users_required to value under minimum" do
        is_expected.to have_xpath "//input[@id='project_users_required'][@type='number'][@placeholder='Users required'][@min='10.0'][@max='1000000.0'][@step='1.0'][@value='#{users_required}']"

        fill_in "project_users_required", with: under_min_users_required

        click_on "Save"

        expect(current_path).to eql "/admin/resources/projects/#{project.id}"
        is_expected.to have_text "Users required must be greater than 9"
      end

      it "changes the users_required to value over maximum" do
        is_expected.to have_xpath "//input[@id='project_users_required'][@type='number'][@placeholder='Users required'][@min='10.0'][@max='1000000.0'][@step='1.0'][@value='#{users_required}']"

        fill_in "project_users_required", with: over_max_users_required

        click_on "Save"

        expect(current_path).to eql "/admin/resources/projects/#{project.id}"
        is_expected.to have_text "Users required must be less than 1000000"
      end

      it "cleares the users_required" do
        is_expected.to have_xpath "//input[@id='project_users_required'][@type='number'][@placeholder='Users required'][@min='10.0'][@max='1000000.0'][@step='1.0'][@value='#{users_required}']"

        fill_in "project_users_required", with: 'nil'

        click_on "Save"

        expect(current_path).to eql "/admin/resources/projects/#{project.id}"
        is_expected.to have_text "Users required is not a number"
      end
    end
  end
end
