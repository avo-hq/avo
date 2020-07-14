require 'rails_helper'

RSpec.describe 'HeadingFields', type: :system do
  describe 'with regular input' do
    let!(:user) { create :user }

    context 'show' do
      it 'checks for normal header' do
        visit "/avocado/resources/users/#{user.id}"

        expect(find_field_element('heading_user_information')).to have_text 'USER INFORMATION'
      end

      it 'checks for html header' do
        visit "/avocado/resources/users/#{user.id}"

        expect(find_field_element('heading_div_class_text_blue_900_uppercase_font_bold_dev_div')).to have_text 'DEV'
        expect(find_field_element('heading_div_class_text_blue_900_uppercase_font_bold_dev_div')).to have_css '.uppercase'
        expect(find_field_element('heading_div_class_text_blue_900_uppercase_font_bold_dev_div')).to have_css '.text-blue-900'
      end
    end

    context 'edit' do
      it 'checks for normal header' do
        visit "/avocado/resources/users/#{user.id}/edit"

        expect(find_field_element('heading_user_information')).to have_text 'USER INFORMATION'
      end
    end

    context 'edit' do
      it 'checks for html header' do
        visit "/avocado/resources/users/#{user.id}/edit"

        expect(find_field_element('heading_div_class_text_blue_900_uppercase_font_bold_dev_div')).to have_text 'DEV'
        expect(find_field_element('heading_div_class_text_blue_900_uppercase_font_bold_dev_div')).to have_css '.uppercase'
        expect(find_field_element('heading_div_class_text_blue_900_uppercase_font_bold_dev_div')).to have_css '.text-blue-900'
      end
    end
  end
end
