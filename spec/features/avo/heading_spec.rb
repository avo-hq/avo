require "rails_helper"

RSpec.describe "heading", type: :feature do
  context "show" do
    let(:url) { "/admin/resources/users/#{user.slug}" }

    describe "with value" do
      let!(:user) { create :user }

      it "checks for normal heading" do
        visit url

        expect(find_field_element("heading_user_information")).to have_text "User information"
      end

      it "checks for html heading" do
        visit url

        expect(find_field_element("heading_dev")).to have_text "DEV"
        expect(find_field_element("heading_dev")).to have_css ".uppercase"
        expect(find_field_element("heading_dev")).to have_css ".underline"
        expect(find_field_element("heading_dev")).to have_css ".font-bold"
      end
    end
  end

  context "edit" do
    let(:url) { "/admin/resources/users/#{user.slug}/edit" }

    describe "with value" do
      let!(:user) { create :user }

      it "checks for normal heading" do
        visit url

        expect(find_field_element("heading_user_information")).to have_text "User information"
      end

      it "checks for html heading" do
        visit url

        expect(find_field_element("heading_dev")).to have_text "DEV"
        expect(find_field_element("heading_dev")).to have_css ".uppercase"
        expect(find_field_element("heading_dev")).to have_css ".underline"
        expect(find_field_element("heading_dev")).to have_css ".font-bold"
      end
    end
  end
end
