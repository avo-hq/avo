require "rails_helper"

RSpec.describe "HeadingFields", type: :system do
  describe "with regular input" do
    let!(:user) { create :user }

    context "show" do
      it "checks for normal header" do
        visit "/admin/resources/users/#{user.id}"

        expect(find_field_element("heading_user_information")).to have_text "USER INFORMATION"
      end

      it "checks for html header" do
        visit "/admin/resources/users/#{user.id}"
        wait_for_loaded

        expect(find_field_element("heading_div_class_underline_uppercase_font_bold_dev_div")).to have_text "DEV"
        expect(find_field_element("heading_div_class_underline_uppercase_font_bold_dev_div")).to have_css ".uppercase"
        expect(find_field_element("heading_div_class_underline_uppercase_font_bold_dev_div")).to have_css ".underline"
        expect(find_field_element("heading_div_class_underline_uppercase_font_bold_dev_div")).to have_css ".font-bold"
      end
    end

    context "edit" do
      it "checks for normal header" do
        visit "/admin/resources/users/#{user.id}/edit"
        wait_for_loaded

        expect(find_field_element("heading_user_information")).to have_text "USER INFORMATION"
      end
    end

    context "edit" do
      it "checks for html header" do
        visit "/admin/resources/users/#{user.id}/edit"
        wait_for_loaded

        expect(find_field_element("heading_div_class_underline_uppercase_font_bold_dev_div")).to have_text "DEV"
        expect(find_field_element("heading_div_class_underline_uppercase_font_bold_dev_div")).to have_css ".uppercase"
        expect(find_field_element("heading_div_class_underline_uppercase_font_bold_dev_div")).to have_css ".underline"
        expect(find_field_element("heading_div_class_underline_uppercase_font_bold_dev_div")).to have_css ".font-bold"
      end
    end
  end
end
