require 'rails_helper'

RSpec.describe 'HeadingFields', type: :system do
  describe 'with regular input' do
    let!(:user) { create :user }

    context 'show' do
      it 'checks for normal header' do
        visit "/avocado/resources/users/#{user.id}"

        expect(find_field_element('heading_age')).to have_text 'AGE'
      end

      it 'checks for html header' do
        visit "/avocado/resources/users/#{user.id}"

        expect(find_field_element('heading_div_class_underline_text_green_800_uppercase_personal_documents_div')).to have_text 'PERSONAL DOCUMENTS'
        expect(find_field_element('heading_div_class_underline_text_green_800_uppercase_personal_documents_div')).to have_css '.underline'
        expect(find_field_element('heading_div_class_underline_text_green_800_uppercase_personal_documents_div')).to have_css '.uppercase'
        expect(find_field_element('heading_div_class_underline_text_green_800_uppercase_personal_documents_div')).to have_css '.text-green-800'
      end
    end

    context 'edit' do
      it 'checks for normal header' do
        visit "/avocado/resources/users/#{user.id}/edit"

        expect(find_field_element('heading_age')).to have_text 'AGE'
      end
    end

    context 'edit' do
      it 'checks for html header' do
        visit "/avocado/resources/users/#{user.id}/edit"

        expect(find_field_element('heading_div_class_underline_text_green_800_uppercase_personal_documents_div')).to have_text 'PERSONAL DOCUMENTS'
        expect(find_field_element('heading_div_class_underline_text_green_800_uppercase_personal_documents_div')).to have_css '.underline'
        expect(find_field_element('heading_div_class_underline_text_green_800_uppercase_personal_documents_div')).to have_css '.uppercase'
        expect(find_field_element('heading_div_class_underline_text_green_800_uppercase_personal_documents_div')).to have_css '.text-green-800'
      end
    end
  end
end
