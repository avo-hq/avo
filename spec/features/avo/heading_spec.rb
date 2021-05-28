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

        expect(find_field_element("heading_div_class_text_gray_300_uppercase_font_bold_dev_div")).to have_text "dev"
        expect(find_field_element("heading_div_class_text_gray_300_uppercase_font_bold_dev_div")).to have_css ".uppercase"
        expect(find_field_element("heading_div_class_text_gray_300_uppercase_font_bold_dev_div")).to have_css ".text-gray-300"
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

        expect(find_field_element("heading_div_class_text_gray_300_uppercase_font_bold_dev_div")).to have_text "dev"
        expect(find_field_element("heading_div_class_text_gray_300_uppercase_font_bold_dev_div")).to have_css ".uppercase"
        expect(find_field_element("heading_div_class_text_gray_300_uppercase_font_bold_dev_div")).to have_css ".text-gray-300"
      end
    end
  end
end
